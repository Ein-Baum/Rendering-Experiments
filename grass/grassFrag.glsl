#version 400 core

in vec3 position;
in float perInstanceRandom;

uniform float indicate;

layout (location = 0) out vec4 color_out;
layout (location = 1) out vec4 depth_out;

// From "sam hocevar" on https://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
// Only used to show the different instances
vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// From "appas" on https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl 
float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(){

    // Grass color (could also be added to instance or vertex data or passed as uniform)
    vec3 upperColor = vec3(0.51, 0.91, 0.62);
    vec3 lowerColor = vec3(0.20, 0.39, 0.31);

    if(indicate > 0){
        upperColor = mix(upperColor, hsv2rgb(vec3(perInstanceRandom,0.5,1)), indicate);
        lowerColor = mix(lowerColor, hsv2rgb(vec3(perInstanceRandom,0.5,0.6)), indicate);
    }

    // Get layer height (normalized)
    float hF = position.z;

    // Get quantized coordinates to get squary grass
    vec2 c = floor(position.xy*10.0)/10.0;

    // Get random punch depth for the current position
    float punch = rand(c);

    // If the current punch depth is higher than this layers height
    if(punch > hF){
        // Draw this pixel (with the color based on the layer height)
        color_out = vec4(mix(lowerColor,upperColor,hF), 1.0);
        // Depth is only drawn seperated because I also did some other stuff with it
        depth_out = vec4(gl_FragCoord.z, 0.0, 0.0, 1.0);
    }else{
        // Or discard this fragment otherwise
        discard;
    }
}
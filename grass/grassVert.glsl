#version 400 core
layout (location = 0) in vec3 geometry; //X, Y, Z
layout (location = 1) in vec4 translate; //Per instance translation (and a random number for coloring)

uniform mat4 viewproj;
uniform float grassSpacing; // The spacing between the grass layers (later multiplied by 20 because there are 20 layers)
uniform float time;

out vec3 position;
out float perInstanceRandom;

void main(){

    // Pass random per instance value
    perInstanceRandom = translate.w;

    // Raw position with computational layering (saves a few bytes of vertex data)
    vec3 rawPos = vec3((geometry.x-.5)*1, geometry.z * grassSpacing * 20, (geometry.y-.5)*1);

    // Position for the fragment shader (without wavy and z translation)
    position = vec3(rawPos.xz+translate.xz, geometry.z);
    
    // Layering sin and cos to get a wavy random looking effect
    vec2 windAnim = vec2(  sin(time+rawPos.x+translate.x)*0.1*sin(time*0.4-19), 
                           cos(time+rawPos.z+translate.z)*0.1*sin(time*2+19));
    
    // Make the wind affect the bottom less, so only the top parts are waving in the wind
    windAnim *= geometry.z;

    // Adding everything together and doing view and projection matrix mul
    gl_Position = viewproj * vec4(rawPos + translate.xyz + vec3(windAnim.x, 0, windAnim.y), 1);
}
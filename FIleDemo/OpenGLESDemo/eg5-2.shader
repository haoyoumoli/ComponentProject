//P117


//Vertex shader
#version 300 es

uniform mat4 u_matViewProjection;

//vertex shader inputs
layout(location = 0) in vec4 a_position;
layout(location = 1) in vec3 a_color;

//vertex shader output
out vec3 v_color;

void main(void)
{
    gl_Position = u_matViewProjection * a_position;
    v_color = a_color;
}


//Fragment shader

#version 300 es
precision mediump float;

//input from vertex shader
in vec3 v_color;

//Output of fragment shader
layout(location = 0) out vec4 o_fragColor;

void main()
{
    o_fragColor = vec4(v_color,1.0);
}



#version 330 compatibility

#include "/lib/common.glsl"
out vec2 texCoord;
out vec2 lmCoord;
out vec4 color;
out vec3 normal;
out vec3 viewPos;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(normalMatrix * gl_Normal);

    vec4 viewPos4 = modelViewMatrix * gl_Vertex;
    viewPos = viewPos4.xyz;
    gl_Position = projectionMatrix * viewPos4;
}

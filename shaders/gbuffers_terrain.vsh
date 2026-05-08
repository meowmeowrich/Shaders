#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"

out vec2 texCoord;
out vec2 lmCoord;
out vec4 color;
out vec3 normal;
out vec3 viewPos;
out vec3 worldPos;
out float blockId;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(normalMatrix * gl_Normal);
    blockId = mc_Entity.x;

    vec4 position = gl_Vertex;

    #ifdef DYNAMIC_WIND
    // Multi-frequency procedural wind
    if (blockId > 10000.0) { // Simple foliage check
        float t = frameTimeCounter;
        float wind = sin(t * 1.5 + position.x * 0.5) * 0.1;
        wind += sin(t * 3.0 + position.z * 0.8) * 0.05;
        position.x += wind * position.y * 0.2;
    }
    #endif

    vec4 viewPos4 = modelViewMatrix * position;
    viewPos = viewPos4.xyz;
    worldPos = (gbufferModelViewInverse * viewPos4).xyz + cameraPosition;
    gl_Position = projectionMatrix * viewPos4;
}

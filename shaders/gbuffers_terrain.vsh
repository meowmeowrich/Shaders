#version 330 compatibility

#include "/lib/settings.glsl"

out vec2 texCoord;
out vec2 lmCoord;
out vec4 color;
out vec3 normal;
out vec3 viewPos;
out float blockId;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

attribute vec4 mc_Entity;

#ifdef DYNAMIC_WIND
vec3 applyWind(vec3 pos, float isFoliage) {
    if (isFoliage < 0.5) return pos;

    float t = frameTimeCounter;
    float wind = sin(t * 1.5 + pos.x * 0.5) * 0.1;
    wind += sin(t * 3.0 + pos.z * 0.8) * 0.05;

    pos.x += wind * pos.y * 0.2;
    return pos;
}
#endif

void main() {
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    normal = normalize(normalMatrix * gl_Normal);
    blockId = mc_Entity.x;

    vec4 position = gl_Vertex;

    #ifdef DYNAMIC_WIND
    // Crude foliage check via mc_Entity or gl_Color/gl_Normal heuristics if needed
    // Typically, foliage might have specific mc_Entity IDs or we use blockId
    bool isFoliage = (blockId > 10000.0); // Placeholder check
    position.xyz = applyWind(position.xyz, isFoliage ? 1.0 : 0.0);
    #endif

    vec4 viewPos4 = modelViewMatrix * position;
    viewPos = viewPos4.xyz;
    gl_Position = projectionMatrix * viewPos4;
}

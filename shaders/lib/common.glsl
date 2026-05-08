#if !defined COMMON_GLSL
#define COMMON_GLSL

#include "/lib/settings.glsl"

// Constants
const float PI = 3.14159265359;
const float TAU = 6.28318530718;

// Math Helpers
float luma(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

// Interleaved Gradient Noise (from Jorge Jimenez)
float IGN(vec2 p) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(p, magic.xy)));
}

// Blue Noise Approximation
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float blueNoise(vec2 p, int frameCounter) {
    return fract(hash12(p) + float(frameCounter % 64) * 0.61803398875);
}

// Space Conversions
vec3 screenToView(vec3 screenPos, mat4 invProj) {
    vec4 ndc = vec4(screenPos * 2.0 - 1.0, 1.0);
    vec4 view = invProj * ndc;
    return view.xyz / view.w;
}

vec3 viewToWorld(vec3 viewPos, mat4 invView) {
    vec4 world = invView * vec4(viewPos, 1.0);
    return world.xyz;
}

vec3 worldToView(vec3 worldPos, mat4 viewMatrix) {
    vec4 view = viewMatrix * vec4(worldPos, 1.0);
    return view.xyz;
}

// Raymarching Utilities
struct Ray {
    vec3 origin;
    vec3 dir;
};

#endif

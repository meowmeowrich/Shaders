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

// Pseudo-Random / Noise
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}

// Blue Noise Approximation
float blueNoise(vec2 p, int frameCounter) {
    return fract(hash12(p) + float(frameCounter % 64) * 0.61803398875);
}

// Space Conversions (Assumes standard Minecraft uniforms)
vec3 screenToView(vec3 screenPos, mat4 invProj) {
    vec4 ndc = vec4(screenPos * 2.0 - 1.0, 1.0);
    vec4 view = invProj * ndc;
    return view.xyz / view.w;
}

vec3 viewToWorld(vec3 viewPos, mat4 invView) {
    vec4 world = invView * vec4(viewPos, 1.0);
    return world.xyz;
}

// Temporal Reprojection
vec2 getPreviousCoord(vec3 screenPos, mat4 invProj, mat4 invView, mat4 prevView, mat4 prevProj) {
    vec3 viewPos = screenToView(screenPos, invProj);
    vec3 worldPos = viewToWorld(viewPos, invView);

    vec4 prevViewPos = prevView * vec4(worldPos, 1.0);
    vec4 prevClipPos = prevProj * prevViewPos;
    vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;

    return prevNDC.xy * 0.5 + 0.5;
}

#endif

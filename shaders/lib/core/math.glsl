#if !defined MATH_GLSL
#define MATH_GLSL

const float PI = 3.14159265358979323846;
const float TAU = 6.28318530717958647692;
const float INV_PI = 0.31830988618;
const float INV_TAU = 0.15915494309;

// Lighting Helpers
float luma(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
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

// Geometric Helpers
vec3 getNormalFromDepth(sampler2D depthTex, vec2 texCoord, mat4 invProj) {
    vec2 off = 1.0 / vec2(textureSize(depthTex, 0));
    float d = texture2D(depthTex, texCoord).r;
    vec3 p = screenToView(vec3(texCoord, d), invProj);

    float d_r = texture2D(depthTex, texCoord + vec2(off.x, 0.0)).r;
    vec3 p_r = screenToView(vec3(texCoord + vec2(off.x, 0.0), d_r), invProj);

    float d_u = texture2D(depthTex, texCoord + vec2(0.0, off.y)).r;
    vec3 p_u = screenToView(vec3(texCoord + vec2(0.0, off.y), d_u), invProj);

    return normalize(cross(p_r - p, p_u - p));
}

#endif

#if !defined SHADOWS_GLSL
#define SHADOWS_GLSL

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

float getShadow(vec3 worldPos) {
    vec4 shadowClip = shadowProjection * (shadowModelView * vec4(worldPos, 1.0));
    vec3 shadowNDC = shadowClip.xyz / shadowClip.w;
    vec3 shadowCoord = shadowNDC * 0.5 + 0.5;

    if (shadowCoord.x < 0.0 || shadowCoord.x > 1.0 || shadowCoord.y < 0.0 || shadowCoord.y > 1.0) return 1.0;

    float depth = texture2D(shadowtex0, shadowCoord.xy).r;
    return shadowCoord.z > depth + 0.001 ? 0.0 : 1.0;
}

#endif

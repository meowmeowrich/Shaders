#if !defined GI_CACHE_GLSL
#define GI_CACHE_GLSL

#include "/lib/core/temporal.glsl"

vec3 sampleGICache(vec3 worldPos, mat4 prevView, mat4 prevProj, sampler2D cacheTex) {
    vec4 prevViewPos = prevView * vec4(worldPos, 1.0);
    vec4 prevClipPos = prevProj * prevViewPos;
    vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;
    vec2 prevCoord = prevNDC.xy * 0.5 + 0.5;

    if (prevCoord.x >= 0.0 && prevCoord.x <= 1.0 && prevCoord.y >= 0.0 && prevCoord.y <= 1.0) {
        return texture2D(cacheTex, prevCoord).rgb;
    }
    return vec3(0.0);
}

#endif

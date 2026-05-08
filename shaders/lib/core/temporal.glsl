#if !defined TEMPORAL_GLSL
#define TEMPORAL_GLSL

#include "/lib/core/math.glsl"

struct ReprojectionResult {
    vec2 prevCoord;
    bool isValid;
};

ReprojectionResult reproject(vec3 screenPos, mat4 invProj, mat4 invView, mat4 prevView, mat4 prevProj) {
    vec3 viewPos = screenToView(screenPos, invProj);
    vec3 worldPos = viewToWorld(viewPos, invView);

    vec4 prevViewPos = prevView * vec4(worldPos, 1.0);
    vec4 prevClipPos = prevProj * prevViewPos;
    vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;

    ReprojectionResult res;
    res.prevCoord = prevNDC.xy * 0.5 + 0.5;
    res.isValid = res.prevCoord.x >= 0.0 && res.prevCoord.x <= 1.0 &&
                  res.prevCoord.y >= 0.0 && res.prevCoord.y <= 1.0;
    return res;
}

#endif

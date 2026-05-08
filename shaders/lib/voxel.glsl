#if !defined VOXEL_GLSL
#define VOXEL_GLSL

#include "/lib/common.glsl"

// Simple World-Space Voxel Light Cache Approximation
// We use a temporal grid to store light values in world space
// Since we don't have true 3D textures in standard Minecraft GLSL easily,
// we approximate using screen-space reprojection and a feedback buffer.

vec3 getVoxelLight(vec3 worldPos, vec3 normal, mat4 prevView, mat4 prevProj) {
    // Project world position to previous frame screen space
    vec4 prevViewPos = prevView * vec4(worldPos, 1.0);
    vec4 prevClipPos = prevProj * prevViewPos;
    vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;
    vec2 prevCoord = prevNDC.xy * 0.5 + 0.5;

    if (prevCoord.x >= 0.0 && prevCoord.x <= 1.0 && prevCoord.y >= 0.0 && prevCoord.y <= 1.0) {
        // Sample from the GI Cache (colortex2)
        return texture2D(colortex2, prevCoord).rgb;
    }
    return vec3(0.0);
}

#endif

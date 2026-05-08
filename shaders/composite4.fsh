#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:05 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outHistory;

uniform sampler2D colortex0;
uniform sampler2D colortex5; // Previous Frame
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

vec3 clipAABB(vec3 nowColor, vec3 historyColor, vec2 coord) {
    vec2 off = 1.0 / vec2(textureSize(colortex0, 0));
    vec3 minC = nowColor, maxC = nowColor;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;
            vec3 neighbor = texture2D(colortex0, coord + vec2(x, y) * off).rgb;
            minC = min(minC, neighbor);
            maxC = max(maxC, neighbor);
        }
    }
    // Narrow the AABB slightly for better responsiveness
    vec3 center = (minC + maxC) * 0.5;
    minC = mix(minC, center, 0.1);
    maxC = mix(maxC, center, 0.1);

    return clamp(historyColor, minC, maxC);
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    // Ensure no NaNs propagate
    if (any(isnan(color)) || any(isinf(color))) color = vec3(0.0);

    #ifdef TAA
    float depth = texture2D(depthtex0, texCoord).r;
    if (depth < 1.0) {
        vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
        vec3 worldPos = viewToWorld(viewPos, gbufferModelViewInverse);

        vec4 prevViewPos = gbufferPreviousModelView * vec4(worldPos, 1.0);
        vec4 prevClipPos = gbufferPreviousProjection * prevViewPos;
        vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;
        vec2 prevCoord = prevNDC.xy * 0.5 + 0.5;

        if (prevCoord.x >= 0.0 && prevCoord.x <= 1.0 && prevCoord.y >= 0.0 && prevCoord.y <= 1.0) {
            vec3 history = texture2D(colortex5, prevCoord).rgb;
            history = clipAABB(color, history, texCoord);
            color = mix(color, history, 0.9);
        }
    }
    #endif

    outColor = vec4(color, 1.0);
    outHistory = vec4(color, 1.0);
}

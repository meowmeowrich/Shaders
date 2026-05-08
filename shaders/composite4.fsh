#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:05 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outPrevColor;

uniform sampler2D colortex0;
uniform sampler2D colortex5; // Previous Frame
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

vec3 clampNeighborhood(vec3 color, vec2 coord) {
    vec2 off = 1.0 / vec2(textureSize(colortex0, 0));
    vec3 m1 = color;
    vec3 m2 = color * color;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;
            vec3 c = texture2D(colortex0, coord + vec2(x, y) * off).rgb;
            m1 += c;
            m2 += c * c;
        }
    }

    vec3 mu = m1 / 9.0;
    vec3 sigma = sqrt(max(m2 / 9.0 - mu * mu, 0.0));
    return clamp(color, mu - sigma * 2.0, mu + sigma * 2.0);
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    #ifdef TAA
    float depth = texture2D(depthtex0, texCoord).r;
    vec3 finalColor = color;

    if (depth < 1.0) {
        vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
        vec3 worldPos = viewToWorld(viewPos, gbufferModelViewInverse);

        vec4 prevViewPos = gbufferPreviousModelView * vec4(worldPos, 1.0);
        vec4 prevClipPos = gbufferPreviousProjection * prevViewPos;
        vec3 prevNDC = prevClipPos.xyz / prevClipPos.w;
        vec2 prevCoord = prevNDC.xy * 0.5 + 0.5;

        if (prevCoord.x >= 0.0 && prevCoord.x <= 1.0 && prevCoord.y >= 0.0 && prevCoord.y <= 1.0) {
            vec3 prevColor = texture2D(colortex5, prevCoord).rgb;
            prevColor = clampNeighborhood(prevColor, texCoord); // Variance clipping
            finalColor = mix(color, prevColor, 0.95);
        }
    }
    color = finalColor;
    #endif

    outColor = vec4(color, 1.0);
    outPrevColor = vec4(color, 1.0);
}

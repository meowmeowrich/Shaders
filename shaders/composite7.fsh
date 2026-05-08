#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:2 */
layout(location = 0) out vec4 outGI; // Upscaled and Denoised GI

uniform sampler2D colortex6; // Path Tracing Buffer
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;

void main() {
    // Edge-aware bilateral filter for upscaling
    vec3 gi = texture2D(colortex6, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    vec2 off = 1.0 / vec2(textureSize(colortex6, 0));
    float totalWeight = 1.0;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;
            vec2 sampleCoord = texCoord + vec2(x, y) * off;
            float d = texture2D(depthtex0, sampleCoord).r;

            float weight = exp(-abs(d - depth) * 100.0);
            gi += texture2D(colortex6, sampleCoord).rgb * weight;
            totalWeight += weight;
        }
    }

    outGI = vec4(gi / totalWeight, 1.0);
}

#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float frameTimeCounter;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth == 1.0) {
        // Simple Cloud Noise Approximation
        float n = hash12(texCoord * 5.0 + frameTimeCounter * 0.005);
        n += hash12(texCoord * 10.0 - frameTimeCounter * 0.01) * 0.5;

        if (n > 1.0) {
            float cloudAlpha = smoothstep(1.0, 1.2, n) * CLOUD_DENSITY;
            color = mix(color, vec3(1.0), cloudAlpha);
        }
    }

    outColor = vec4(color, 1.0);
}

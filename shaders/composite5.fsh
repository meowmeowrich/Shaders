#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"
#include "/lib/core/temporal.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:05 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outHistory;

uniform sampler2D colortex0;
uniform sampler2D colortex5; // History
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

vec3 clipAABB(vec3 now, vec3 history, vec2 coord) {
    vec2 off = 1.0 / vec2(textureSize(colortex0, 0));
    vec3 m1 = now, m2 = now * now;

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
    return clamp(history, mu - sigma * 2.0, mu + sigma * 2.0);
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    #ifdef TAA
    float depth = texture2D(depthtex0, texCoord).r;
    if (depth < 1.0) {
        ReprojectionResult res = reproject(vec3(texCoord, depth), gbufferProjectionInverse, gbufferModelViewInverse, gbufferPreviousModelView, gbufferPreviousProjection);

        if (res.isValid) {
            vec3 history = texture2D(colortex5, res.prevCoord).rgb;
            history = clipAABB(color, history, texCoord);
            color = mix(color, history, 0.95);
        }
    }
    #endif

    outColor = vec4(color, 1.0);
    outHistory = vec4(color, 1.0);
}

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

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    #ifdef TAA
    float depth = texture2D(depthtex0, texCoord).r;
    if (depth < 1.0) {
        vec2 prevCoord = getPreviousCoord(vec3(texCoord, depth), gbufferProjectionInverse, gbufferModelViewInverse, gbufferPreviousModelView, gbufferPreviousProjection);

        if (prevCoord.x >= 0.0 && prevCoord.x <= 1.0 && prevCoord.y >= 0.0 && prevCoord.y <= 1.0) {
            vec3 prevColor = texture2D(colortex5, prevCoord).rgb;
            color = mix(color, prevColor, 0.9); // Heavy accumulation for stability
        }
    }
    #endif

    outColor = vec4(color, 1.0);
    outPrevColor = vec4(color, 1.0);
}

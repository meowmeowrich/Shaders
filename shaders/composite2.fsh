#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;
    float smoothness = texture2D(colortex1, texCoord).a;

    #ifdef SSR
    if (smoothness > 0.5 && depth < 1.0) {
        // Placeholder for Screen Space Reflections logic
        color += vec3(0.05) * smoothness;
    }
    #endif

    outColor = vec4(color, 1.0);
}

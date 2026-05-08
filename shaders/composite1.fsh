#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"
#include "/lib/lighting/gi_cache.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:02 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outIndirect;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2; // Cache feedback
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth >= 1.0) {
        outColor = vec4(color, 1.0);
        outIndirect = vec4(0.0);
        return;
    }

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    vec3 worldPos = viewToWorld(viewPos, gbufferModelViewInverse);
    vec3 normal = texture2D(colortex1, texCoord).rgb * 2.0 - 1.0;

    vec3 indirect = sampleGICache(worldPos + normal * 0.1, gbufferPreviousModelView, gbufferPreviousProjection, colortex2);

    // Low-frequency ambient fallback
    vec3 ambient = vec3(0.05, 0.06, 0.08) * color;
    indirect = mix(ambient, indirect, 0.8) * GI_BOUNCE_INTENSITY;

    outColor = vec4(color + indirect, 1.0);
    outIndirect = vec4(indirect, 1.0);
}

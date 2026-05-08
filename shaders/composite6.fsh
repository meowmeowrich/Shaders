#version 330 compatibility

#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:6 */
layout(location = 0) out vec4 outPathTrace;

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normals
uniform sampler2D colortex6; // Self-feedback
uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform int frameCounter;

void main() {
    ivec2 pixel = ivec2(gl_FragCoord.xy);
    bool update = (frameCounter % 2 == (pixel.x + pixel.y) % 2);

    if (!update) {
        outPathTrace = texture2D(colortex6, texCoord);
        return;
    }

    float depth = texture2D(depthtex0, texCoord).r;
    if (depth >= 1.0) {
        outPathTrace = vec4(0.0);
        return;
    }

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    vec3 normal = texture2D(colortex1, texCoord).rgb * 2.0 - 1.0;

    vec3 indirect = vec3(0.0);
    float jitter = blueNoise(texCoord, frameCounter);

    // Improved Screen Space Path Tracing
    vec3 rayDir = normalize(normal + hash33(vec3(texCoord, jitter)) * 2.0 - 1.0);
    if (rayDir.z > 0.0) rayDir.z *= -1.0; // Force ray into the scene

    vec3 p = viewPos + rayDir * 0.1;
    for(int i = 0; i < 12; i++) {
        vec4 proj = gbufferProjection * vec4(p, 1.0);
        vec3 screen = (proj.xyz / proj.w) * 0.5 + 0.5;

        if (screen.x < 0.0 || screen.x > 1.0 || screen.y < 0.0 || screen.y > 1.0) break;

        float d = texture2D(depthtex0, screen.xy).r;
        vec3 hitPos = screenToView(vec3(screen.xy, d), gbufferProjectionInverse);

        if (p.z < hitPos.z && length(p - hitPos) < 1.2) {
            // Found a hit, sample color and accumulate
            indirect = texture2D(colortex0, screen.xy).rgb * 0.5 * GI_BOUNCE_INTENSITY;
            break;
        }
        p += rayDir * 1.5;
    }

    vec3 prevGI = texture2D(colortex6, texCoord).rgb;
    outPathTrace = vec4(mix(prevGI, indirect, 0.2), 1.0);
}

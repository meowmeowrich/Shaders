#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:02 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outIndirect;

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal/Smoothness
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float nightVision;
uniform int worldTime;

void main() {
    vec3 albedo = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth == 1.0) {
        outColor = vec4(albedo, 1.0);
        outIndirect = vec4(0.0);
        return;
    }

    vec3 normal = texture2D(colortex1, texCoord).rgb * 2.0 - 1.0;
    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);

    vec3 L = normalize(sunPosition);
    float NdotL = max(dot(normal, L), 0.0);

    // Day/Night Cycle Strength
    float sunStrength = smoothstep(-0.1, 0.1, sunPosition.y);

    // Hybrid Lighting Approximation
    vec3 ambient = vec3(0.02, 0.03, 0.05) * (1.0 - nightVision);
    vec3 skyLight = vec3(0.1, 0.15, 0.25) * sunStrength;

    // Fake "Bounce" - tinted by albedo and a generic "ground" color
    vec3 bounce = albedo * vec3(0.8, 0.7, 0.5) * GI_BOUNCE_INTENSITY * 0.05 * sunStrength;

    vec3 lighting = albedo * (NdotL * sunStrength * 1.5 + ambient + skyLight + bounce);

    outColor = vec4(lighting, 1.0);
    outIndirect = vec4(bounce, 1.0);
}

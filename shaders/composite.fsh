#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/shadows.glsl"
#include "/lib/common.glsl"
#include "/lib/brdf.glsl"
#include "/lib/voxel.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:02 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outIndirect;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2; // GI Cache Feedback
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 sunPosition;
uniform int frameCounter;

void main() {
    vec4 albedoData = texture2D(colortex0, texCoord);
    vec3 albedo = albedoData.rgb;
    float emissive = albedoData.a;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth >= 1.0) {
        outColor = vec4(albedo, 1.0);
        outIndirect = vec4(0.0);
        return;
    }

    vec4 data = texture2D(colortex1, texCoord);
    vec3 normal = normalize(data.rgb * 2.0 - 1.0 + 0.0001);
    float roughness = max(data.a, 0.02);

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    vec3 worldPos = viewToWorld(viewPos, gbufferModelViewInverse);
    vec3 V = normalize(-viewPos);
    vec3 L = normalize(sunPosition);

    float sunStrength = smoothstep(-0.1, 0.1, sunPosition.y);
    vec3 F0 = mix(vec3(0.04), albedo, 0.5);

    // Direct PBR
    vec3 specular = specularBRDF(normal, V, L, roughness, F0);
    float NdotL = max(dot(normal, L), 0.0);
    float shadow = getShadow(worldPos);
    vec3 direct = albedo * NdotL * sunStrength * 1.5 * shadow + specular * sunStrength * shadow;

    // Voxel-Inspired Indirect
    vec3 indirect = getVoxelLight(worldPos + normal * 0.1, normal, gbufferPreviousModelView, gbufferPreviousProjection);

    // Local bounce approximation for when cache is empty or for extra detail
    vec3 localBounce = albedo * vec3(0.05, 0.07, 0.1) * (1.0 - sunStrength * 0.5);
    indirect = mix(localBounce, indirect, 0.8) * GI_BOUNCE_INTENSITY;

    vec3 final = direct + indirect + albedo * emissive * EMISSIVE_STRENGTH;

    if (any(isnan(final)) || any(isinf(final))) final = albedo * 0.1;

    outColor = vec4(final, 1.0);
    outIndirect = vec4(indirect, 1.0);
}

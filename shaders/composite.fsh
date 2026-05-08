#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/lighting/brdf.glsl"
#include "/lib/lighting/shadows.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor;

uniform sampler2D colortex0; // Scene
uniform sampler2D colortex1; // Normal/Roughness
uniform sampler2D colortex2; // GI Cache
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;

void main() {
    vec4 albedoData = texture2D(colortex0, texCoord);
    vec3 albedo = albedoData.rgb;
    float emissive = albedoData.a;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth >= 1.0) {
        outColor = vec4(albedo, 1.0);
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

    // Direct PBR with Dramatic Shadows
    vec3 specular = cookTorranceSpecular(normal, V, L, roughness, F0);
    float NdotL = max(dot(normal, L), 0.0);
    float shadow = getShadow(worldPos);

    vec3 direct = (albedo * NdotL + specular) * sunStrength * shadow * 1.5;

    // GI / Path Traced Data
    vec3 gi = texture2D(colortex2, texCoord).rgb;

    // Dramatic Light Wrap (Subsurface Scatter look)
    float wrap = smoothstep(0.0, 0.8, 1.0 - NdotL) * 0.2 * sunStrength * shadow;

    vec3 final = direct + gi + albedo * emissive * EMISSIVE_STRENGTH + albedo * wrap;

    if (any(isnan(final)) || any(isinf(final))) final = albedo * 0.1;

    outColor = vec4(final, 1.0);
}

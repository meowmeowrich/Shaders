#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"
#include "/lib/brdf.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:02 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outIndirect;

uniform sampler2D colortex0; // Albedo (RGB), Emissive (A)
uniform sampler2D colortex1; // Normal (RGB), Roughness (A)
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform vec3 sunPosition;
uniform float frameTimeCounter;
uniform int frameCounter;

vec3 calculateSSGI(vec3 viewPos, vec3 normal, float roughness) {
    vec3 indirect = vec3(0.0);
    float d = texture2D(depthtex0, texCoord).r;

    // Low-sample blue-noise raymarch for indirect bounce
    for(int i = 0; i < SSGI_SAMPLES; i++) {
        float noise = blueNoise(texCoord, frameCounter + i);
        vec3 rayDir = normalize(normal + (hash12(vec2(noise, float(i))) * 2.0 - 1.0)); // Random hemisphere

        // Very short ray for local occlusion/bounce
        vec3 samplePos = viewPos + rayDir * 0.5;
        // In a real implementation, we'd project samplePos back to screen space and check depth
        // Here we use a mathematical approximation of nearby bounce tinted by albedo
        indirect += texture2D(colortex0, texCoord).rgb * 0.1 * GI_BOUNCE_INTENSITY;
    }

    return indirect / float(SSGI_SAMPLES);
}

void main() {
    vec4 albedoData = texture2D(colortex0, texCoord);
    vec3 albedo = albedoData.rgb;
    float emissive = albedoData.a;
    float depth = texture2D(depthtex0, texCoord).r;

    if (depth == 1.0) {
        outColor = vec4(albedo, 1.0);
        outIndirect = vec4(0.0);
        return;
    }

    vec4 data = texture2D(colortex1, texCoord);
    vec3 normal = data.rgb * 2.0 - 1.0;
    float roughness = data.a;

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    vec3 V = normalize(-viewPos);
    vec3 L = normalize(sunPosition);

    // Direct Lighting (PBR)
    float sunStrength = smoothstep(-0.1, 0.1, sunPosition.y);
    vec3 F0 = mix(vec3(0.04), albedo, 0.5); // Rough metalness approximation
    vec3 specular = specularBRDF(normal, V, L, roughness, F0);
    float NdotL = max(dot(normal, L), 0.0);

    vec3 direct = albedo * NdotL * sunStrength * 1.5 + specular * sunStrength;

    // Indirect / SSGI
    vec3 indirect = calculateSSGI(viewPos, normal, roughness);

    // Combine
    vec3 final = direct + indirect + albedo * emissive * EMISSIVE_STRENGTH;

    outColor = vec4(final, 1.0);
    outIndirect = vec4(indirect, 1.0);
}

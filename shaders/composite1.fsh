#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:03 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outVolumetric;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform vec3 sunPosition;
uniform int frameCounter;

// Henyey-Greenstein Phase Function for scattering
float phase(float cosTheta, float g) {
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5));
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    vec3 rayDir = normalize(viewPos);
    float maxDist = length(viewPos);

    vec3 sunDir = normalize(sunPosition);
    vec3 fogColor = mix(vec3(0.05, 0.05, 0.1), vec3(0.7, 0.8, 1.0), smoothstep(-0.1, 0.2, sunDir.y));

    vec3 volumetric = vec3(0.0);
    float transmittance = 1.0;

    #ifdef VOLUMETRIC_FOG
    // Temporal jitter for froxel-like effect
    float jitter = blueNoise(texCoord, frameCounter);
    int steps = VOLUMETRIC_STEPS;
    float stepSize = maxDist / float(steps);

    for(int i = 0; i < steps; i++) {
        float d = (float(i) + jitter) * stepSize;
        vec3 p = rayDir * d;

        // Localized density based on world height (placeholder for froxel grid)
        float density = exp(-p.y * 0.1) * 0.01 * FOG_VARIATION;

        // In-scattering
        float cosTheta = dot(rayDir, -sunDir);
        float pSun = phase(cosTheta, 0.8);
        volumetric += fogColor * density * pSun * transmittance;

        transmittance *= exp(-density * stepSize);
        if (transmittance < 0.01) break;
    }
    #endif

    outColor = vec4(color * transmittance + volumetric, 1.0);
    outVolumetric = vec4(volumetric, 1.0);
}

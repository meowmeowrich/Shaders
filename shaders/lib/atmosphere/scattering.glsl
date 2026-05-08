#if !defined SCATTERING_GLSL
#define SCATTERING_GLSL

#include "/lib/core/math.glsl"

float phaseRayleigh(float cosTheta) {
    return 3.0 / (16.0 * PI) * (1.0 + cosTheta * cosTheta);
}

float phaseMie(float cosTheta, float g) {
    float g2 = g * g;
    return (3.0 / (8.0 * PI) * ((1.0 - g2) * (1.0 + cosTheta * cosTheta)) / ((2.0 + g2) * pow(1.0 + g2 - 2.0 * g * cosTheta, 1.5)));
}

vec3 getAtmosphericLight(vec3 viewDir, vec3 sunDir, float dist, vec3 sunColor) {
    float cosTheta = dot(viewDir, -sunDir);

    // Rayleigh (Blue Sky)
    vec3 rayleigh = vec3(0.05, 0.2, 0.5) * phaseRayleigh(cosTheta);

    // Mie (Sun Glow)
    vec3 mie = vec3(0.4, 0.3, 0.2) * phaseMie(cosTheta, 0.8);

    // Ozone Absorption (Yellow/Orange at horizon)
    vec3 ozone = vec3(0.05, 0.1, 0.01) * smoothstep(-0.2, 0.1, sunDir.y);

    float fog = 1.0 - exp(-dist * 0.003);
    vec3 scatter = (rayleigh + mie) * sunColor;
    return mix(vec3(0.0), scatter - ozone, fog);
}

#endif

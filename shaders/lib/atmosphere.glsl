#if !defined ATMOSPHERE_GLSL
#define ATMOSPHERE_GLSL

#include "/lib/common.glsl"

// High-fidelity scattering with multiple layers
vec3 getAtmosphericScattering(vec3 viewDir, vec3 sunDir, float dist) {
    float cosTheta = dot(viewDir, -sunDir);

    // Mie Scattering (Sun Glow)
    float mie = pow(max(cosTheta, 0.0), 32.0) * 5.0;
    float mie2 = pow(max(cosTheta, 0.0), 4.0) * 0.5;

    // Rayleigh Scattering (Sky Tint)
    vec3 rayleigh = mix(vec3(0.01, 0.05, 0.2), vec3(0.5, 0.7, 1.0), smoothstep(-0.2, 0.5, sunDir.y));

    // Horizon tint
    float horizon = 1.0 - abs(viewDir.y);
    vec3 horizonColor = mix(vec3(1.0, 0.4, 0.1), vec3(0.7, 0.8, 1.0), smoothstep(-0.1, 0.2, sunDir.y));
    rayleigh = mix(rayleigh, horizonColor, pow(horizon, 4.0));

    vec3 finalSky = rayleigh + (mie + mie2) * vec3(1.0, 0.9, 0.7) * smoothstep(-0.1, 0.1, sunDir.y);

    float fog = 1.0 - exp(-dist * 0.002 * FOG_VARIATION);
    return mix(vec3(0.0), finalSky, fog);
}

#endif

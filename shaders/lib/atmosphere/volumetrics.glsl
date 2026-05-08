#if !defined VOLUMETRICS_GLSL
#define VOLUMETRICS_GLSL

#include "/lib/common.glsl"
#include "/lib/lighting/shadows.glsl"

vec3 getVolumetricLighting(vec3 viewDir, vec3 sunDir, float maxDist, int steps, float jitter, mat4 invView) {
    vec3 volumetric = vec3(0.0);
    float stepSize = maxDist / float(steps);

    for(int i = 0; i < steps; i++) {
        float d = (float(i) + jitter) * stepSize;
        vec3 pView = viewDir * d;
        vec3 pWorld = (invView * vec4(pView, 1.0)).xyz;

        float shadow = getShadow(pWorld);

        // Multi-layered density
        float noise = noise3D(pWorld * 0.1 + vec3(0.0, frameCounter * 0.01, 0.0));
        float density = mix(0.005, 0.05, noise) * exp(-pWorld.y * 0.08);

        // Sun Phase (Henyey-Greenstein)
        float cosTheta = dot(viewDir, -sunDir);
        float phase = (1.0 - 0.8*0.8) / (4.0 * PI * pow(1.0 + 0.8*0.8 - 2.0*0.8*cosTheta, 1.5));

        volumetric += vec3(1.0, 0.9, 0.8) * density * shadow * phase;
    }

    return volumetric / float(steps);
}

#endif

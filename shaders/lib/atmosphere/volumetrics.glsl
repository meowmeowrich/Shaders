#if !defined VOLUMETRICS_GLSL
#define VOLUMETRICS_GLSL

#include "/lib/core/noise.glsl"
#include "/lib/lighting/shadows.glsl"

vec3 getVolumetricLighting(vec3 viewDir, vec3 sunDir, float maxDist, int steps, float jitter, mat4 invView) {
    vec3 volumetric = vec3(0.0);
    float stepSize = maxDist / float(steps);

    for(int i = 0; i < steps; i++) {
        float d = (float(i) + jitter) * stepSize;
        vec3 pView = viewDir * d;
        vec3 pWorld = (invView * vec4(pView, 1.0)).xyz;

        float shadow = getShadow(pWorld);
        float density = exp(-pWorld.y * 0.05) * 0.02;
        volumetric += vec3(1.0, 0.9, 0.8) * density * shadow;
    }

    return volumetric / float(steps);
}

#endif

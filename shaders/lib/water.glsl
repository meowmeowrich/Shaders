#if !defined WATER_GLSL
#define WATER_GLSL

#include "/lib/common.glsl"

float getGerstnerWave(vec2 p, vec2 dir, float steepness, float waveLength, float speed, float time) {
    float k = TAU / waveLength;
    float c = sqrt(9.8 / k);
    float f = k * (dot(dir, p) - c * time * speed);
    float a = steepness / k;
    return a * sin(f);
}

vec3 getWaterNormal(vec3 worldPos, float time) {
    vec2 p = worldPos.xz;
    float h = 0.0;
    h += getGerstnerWave(p, vec2(1.0, 0.0), 0.2, 10.0, 1.0, time);
    h += getGerstnerWave(p, vec2(0.7, 0.7), 0.1, 5.0, 1.2, time);
    h += getGerstnerWave(p, vec2(0.0, 1.0), 0.15, 8.0, 0.8, time);

    float epsilon = 0.1;
    float dx = getGerstnerWave(p + vec2(epsilon, 0.0), vec2(1.0, 0.0), 0.2, 10.0, 1.0, time) - h;
    float dz = getGerstnerWave(p + vec2(0.0, epsilon), vec2(0.0, 1.0), 0.15, 8.0, 0.8, time) - h;

    return normalize(vec3(-dx, epsilon, -dz));
}

#endif

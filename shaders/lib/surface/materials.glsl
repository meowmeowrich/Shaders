#if !defined MATERIALS_GLSL
#define MATERIALS_GLSL

#include "/lib/core/noise.glsl"

struct MaterialProperties {
    float roughness;
    float metalness;
    float emissive;
    float f0;
    bool isWater;
};

MaterialProperties classifyMaterial(vec3 albedo, float blockId, vec2 texCoord) {
    MaterialProperties m;
    m.roughness = 0.7;
    m.metalness = 0.0;
    m.emissive = 0.0;
    m.f0 = 0.04;
    m.isWater = (blockId > 1.9 && blockId < 2.1); // Placeholder

    float l = dot(albedo, vec3(0.2126, 0.7152, 0.0722));

    if (l > 0.9) m.roughness = 0.2;
    if (l < 0.1) m.roughness = 0.9;

    // Procedural Detail
    m.roughness = clamp(m.roughness + (IGN(texCoord * 1024.0) - 0.5) * 0.1, 0.02, 1.0);

    return m;
}

#endif

#if !defined MATERIAL_GLSL
#define MATERIAL_GLSL

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

struct Material {
    float roughness;
    float metalness;
    float emissive;
    float f0;
};

Material getMaterial(vec3 albedo, float blockId, vec2 coord) {
    Material m;
    m.roughness = 0.8;
    m.metalness = 0.0;
    m.emissive = 0.0;
    m.f0 = 0.04;

    #ifdef PROCEDURAL_PBR
    float l = luma(albedo);

    // Heuristic: Darker things often rougher, but some are polished stone
    if (l < 0.3) m.roughness = 0.9;
    if (l > 0.8) m.roughness = 0.3;

    // Metal detection: high saturation or specific luma levels
    float sat = max(albedo.r, max(albedo.g, albedo.b)) - min(albedo.r, min(albedo.g, albedo.b));
    if (sat > 0.5 && l > 0.6) {
        m.metalness = 0.8;
        m.roughness = 0.2;
    }

    // Emissive detection
    if (max(albedo.r, max(albedo.g, albedo.b)) > 0.9 && l > 0.85) {
        m.emissive = 1.0;
    }
    #endif

    #ifdef MICRO_DETAIL
    // Add micro-roughness variations based on texture detail
    float detail = IGN(coord * 1024.0);
    m.roughness = clamp(m.roughness + (detail - 0.5) * 0.1, 0.0, 1.0);
    #endif

    return m;
}

#endif

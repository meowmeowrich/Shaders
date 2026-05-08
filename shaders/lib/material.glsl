#if !defined MATERIAL_GLSL
#define MATERIAL_GLSL

#include "/lib/settings.glsl"

struct Material {
    float smoothness;
    float metalness;
    float emissive;
    float f0; // Base reflectivity
};

Material getMaterial(vec3 albedo, float blockId) {
    Material m;
    m.smoothness = 0.0;
    m.metalness = 0.0;
    m.emissive = 0.0;
    m.f0 = 0.04;

    #ifdef PROCEDURAL_PBR
    // Rough Heuristics for modded compatibility
    float l = dot(albedo, vec3(0.3, 0.59, 0.11));

    // Stone-like
    if (l < 0.5) m.smoothness = 0.1;

    // Metal-like (shiny/dark or very bright)
    if (l > 0.8 || (l < 0.2 && albedo.g > albedo.r)) {
        m.metalness = 0.5;
        m.smoothness = 0.7;
    }

    // Emissive detection (heuristic)
    if (max(albedo.r, max(albedo.g, albedo.b)) > 0.95 && l > 0.8) {
        m.emissive = 1.0;
    }

    // Hardcoded vanilla-ish ranges if blockId is available
    // Iris provides mc_Entity.x as block ID in some contexts
    if (blockId > 10.0 && blockId < 20.0) { // Example: Ores
        m.smoothness = 0.4;
    }
    #endif

    return m;
}

#endif

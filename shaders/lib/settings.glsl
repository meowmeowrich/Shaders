#if !defined SETTINGS_GLSL
#define SETTINGS_GLSL

// Visual Quality Presets (0: Potato, 1: Low, 2: Medium, 3: High, 4: Ultra, 5: Cinematic)
#if !defined VISUAL_QUALITY
    #define VISUAL_QUALITY 3
#endif

// Lighting Mode (0: Fast, 1: Hybrid GI, 2: Full Path-Approx)
#if !defined LIGHTING_MODE
    #define LIGHTING_MODE 1
#endif

// Feature Toggles
#define VOLUMETRIC_FOG
#define SSR
#define TAA
#define BLOOM
#define PROCEDURAL_PBR
#define DYNAMIC_WIND

// Tuning
#define GI_BOUNCE_INTENSITY 1.0
#define EMISSIVE_STRENGTH 1.5
#define CLOUD_DENSITY 0.5
#define FOG_VARIATION 0.8
#define WATER_REFRACTION_STRENGTH 0.05

#endif

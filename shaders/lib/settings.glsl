#if !defined SETTINGS_GLSL
#define SETTINGS_GLSL

// Visual Quality Presets (0-5)
#if !defined VISUAL_QUALITY
    #define VISUAL_QUALITY 5
#endif

// Performance Budgets
#define SSGI_SAMPLES 16
#define VOLUMETRIC_STEPS 96
#define REFLECTION_STEPS 32

// Lighting Mode
#define LIGHTING_MODE 2

// Feature Toggles
#define VOLUMETRIC_FOG
#define SSR
#define TAA
#define BLOOM
#define PROCEDURAL_PBR
#define DYNAMIC_WIND
#define MICRO_DETAIL
#define LENS_FLARE

// Tuning
#define GI_BOUNCE_INTENSITY 2.0
#define EMISSIVE_STRENGTH 2.0
#define CLOUD_DENSITY 0.6
#define FOG_VARIATION 1.0
#define WATER_REFRACTION_STRENGTH 0.08
#define CINEMATIC_CONTRAST 1.1

#endif

#if !defined BIOMES_GLSL
#define BIOMES_GLSL

struct BiomeData {
    vec3 fogColor;
    float fogDensity;
    float leafWind;
};

BiomeData getBiomeData(int biomeId) {
    BiomeData b;
    b.fogColor = vec3(0.5, 0.6, 0.7);
    b.fogDensity = 1.0;
    b.leafWind = 1.0;

    // Crude biome mapping
    if (biomeId == 1) { // Plains
        b.leafWind = 1.2;
    } else if (biomeId == 4) { // Forest
        b.fogDensity = 1.5;
    }

    return b;
}

#endif

#if !defined NOISE_GLSL
#define NOISE_GLSL

// Hash without sine
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 hash33(vec3 p3) {
	p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

// Interleaved Gradient Noise
float IGN(vec2 p) {
    vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
    return fract(magic.z * fract(dot(p, magic.xy)));
}

// Blue Noise Approximation
float blueNoise(vec2 p, int frameCounter) {
    return fract(hash12(p) + float(frameCounter % 64) * 0.61803398875);
}

// Simple 3D Noise
float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float n = dot(i, vec3(1.0, 57.0, 113.0));
    return mix(mix(mix(hash12(vec2(n + 0.0, 0.0)), hash12(vec2(n + 1.0, 0.0)), f.x),
                   mix(hash12(vec2(n + 57.0, 0.0)), hash12(vec2(n + 58.0, 0.0)), f.x), f.y),
               mix(mix(hash12(vec2(n + 113.0, 0.0)), hash12(vec2(n + 114.0, 0.0)), f.x),
                   mix(hash12(vec2(n + 170.0, 0.0)), hash12(vec2(n + 171.0, 0.0)), f.x), f.y), f.z);
}

#endif

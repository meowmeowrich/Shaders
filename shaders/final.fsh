#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;
uniform float frameTimeCounter;

// Simple ACES Tonemapping
vec3 aces(vec3 x) {
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;

    #ifdef TAA
    // TAA would normally be implemented in a separate composite pass
    // using reprojection. For simplicity in this final pass, we just ensure
    // we have the right output.
    #endif

    #ifdef BLOOM
    // Fake Bloom: Sample downscaled versions or just a slight blur of bright areas
    // Here we just do a tiny color boost to simulate glow
    float l = luma(color);
    if (l > 0.8) color += color * 0.2;
    #endif

    // Tone mapping and Gamma correction
    color = aces(color);
    color = pow(color, vec3(1.0/2.2));

    // Artistic Color Grading
    color *= vec3(1.05, 1.0, 0.95); // Slightly warm

    gl_FragColor = vec4(color, 1.0);
}

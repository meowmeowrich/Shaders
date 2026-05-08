#version 330 compatibility

#include "/lib/common.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float frameTimeCounter;

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

    #ifdef BLOOM
    // Enhanced High-Quality Bloom (Multi-tap blur)
    vec2 off = 1.0 / vec2(textureSize(colortex0, 0));
    vec3 bloom = vec3(0.0);
    for(int x = -2; x <= 2; x++) {
        for(int y = -2; y <= 2; y++) {
            bloom += texture2D(colortex0, texCoord + vec2(x, y) * off * 2.0).rgb;
        }
    }
    color += (bloom / 25.0) * 0.3;
    #endif

    // Professional Grading
    color *= 1.1; // Exposure
    color = mix(vec3(dot(color, vec3(0.2126, 0.7152, 0.0722))), color, 1.15); // Saturation boost

    color = aces(color);
    color = pow(color, vec3(1.0/2.2)); // Gamma correction

    // Cinematic Vignette
    vec2 v = texCoord * (1.0 - texCoord.yx);
    float vignette = v.x*v.y * 15.0;
    color *= pow(vignette, 0.15);

    gl_FragColor = vec4(color, 1.0);
}

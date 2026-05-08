#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;
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
    // High-quality fake bloom using a small kernel
    vec2 off = 2.0 / vec2(textureSize(colortex0, 0));
    vec3 blur = vec3(0.0);
    blur += texture2D(colortex0, texCoord + vec2(off.x, 0.0)).rgb;
    blur += texture2D(colortex0, texCoord - vec2(off.x, 0.0)).rgb;
    blur += texture2D(colortex0, texCoord + vec2(0.0, off.y)).rgb;
    blur += texture2D(colortex0, texCoord - vec2(0.0, off.y)).rgb;
    color += (blur / 4.0) * 0.3;
    #endif

    #ifdef LENS_FLARE
    vec2 center = vec2(0.5);
    float d = length(texCoord - center);
    color += vec3(0.1, 0.05, 0.02) * max(0.0, 1.0 - d * 2.0) * 0.1;
    #endif

    // Cinematic Grading
    color = pow(color, vec3(CINEMATIC_CONTRAST));
    color = aces(color);
    color = pow(color, vec3(1.0/2.2));

    // Slight blue shift in shadows
    color.b += (1.0 - luma(color)) * 0.02;

    gl_FragColor = vec4(color, 1.0);
}

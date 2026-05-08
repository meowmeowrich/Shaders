#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"

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

    // Tonemapping and Gamma
    color = aces(color * 1.05);
    color = pow(color, vec3(1.0/2.2));

    // Artistic Contrast and Saturation
    float l = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(l), color, 1.1); // Saturation boost
    color = pow(color, vec3(CINEMATIC_CONTRAST));

    gl_FragColor = vec4(color, 1.0);
}

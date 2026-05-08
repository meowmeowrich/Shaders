#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float frameTimeCounter;

// High-fidelity tonemapping and grading
vec3 tonemap(vec3 x) {
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
    vec2 off = 1.5 / vec2(textureSize(colortex0, 0));
    vec3 bloom = vec3(0.0);
    bloom += texture2D(colortex0, texCoord + vec2(off.x, off.y)).rgb;
    bloom += texture2D(colortex0, texCoord - vec2(off.x, off.y)).rgb;
    bloom += texture2D(colortex0, texCoord + vec2(off.x, -off.y)).rgb;
    bloom += texture2D(colortex0, texCoord - vec2(off.x, -off.y)).rgb;
    color += (bloom / 4.0) * 0.25;
    #endif

    color = tonemap(color * 1.1);
    color = pow(color, vec3(1.0/2.2));

    // Vignette
    vec2 v = texCoord * (1.0 - texCoord.yx);
    float vignette = v.x*v.y * 15.0;
    color *= pow(vignette, 0.1);

    gl_FragColor = vec4(color, 1.0);
}

#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:03 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outVolumetric;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform float frameTimeCounter;
uniform vec3 sunPosition;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    vec3 sunDir = normalize(sunPosition);
    vec3 fogColor = mix(vec3(0.1, 0.1, 0.2), vec3(0.5, 0.6, 0.7), smoothstep(-0.1, 0.2, sunDir.y));

    float fogDensity = 0.0;

    #ifdef VOLUMETRIC_FOG
    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    float dist = length(viewPos);

    // Exponential fog
    fogDensity = 1.0 - exp(-dist * 0.005 * FOG_VARIATION);

    // Sun Glow in fog
    vec3 viewDir = normalize(viewPos);
    float sunGlow = pow(max(dot(viewDir, -sunDir), 0.0), 8.0) * 0.5;
    fogColor += vec3(1.0, 0.8, 0.5) * sunGlow;
    #endif

    outColor = vec4(mix(color, fogColor, fogDensity), 1.0);
    outVolumetric = vec4(fogColor * fogDensity, 1.0);
}

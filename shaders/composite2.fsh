#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"
#include "/lib/atmosphere/scattering.glsl"
#include "/lib/atmosphere/volumetrics.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:03 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outVolumetric;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform int frameCounter;

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;

    vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
    float dist = length(viewPos);
    vec3 viewDir = viewPos / dist;
    vec3 sunDir = normalize(sunPosition);

    vec3 sunColor = vec3(1.0, 0.9, 0.8) * smoothstep(-0.1, 0.1, sunDir.y);
    vec3 atmospheric = getAtmosphericLight(viewDir, sunDir, dist, sunColor);

    float jitter = blueNoise(texCoord, frameCounter);
    vec3 volumetric = getVolumetricLighting(viewDir, sunDir, min(dist, 100.0), VOLUMETRIC_STEPS / 4, jitter, gbufferModelViewInverse);

    outColor = vec4(color + atmospheric + volumetric * 3.0, 1.0);
    outVolumetric = vec4(volumetric, 1.0);
}

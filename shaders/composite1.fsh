#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"
#include "/lib/atmosphere.glsl"
#include "/lib/shadows.glsl"

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

    vec3 scattering = getAtmosphericScattering(viewDir, sunDir, dist);

    vec3 volumetric = vec3(0.0);
    #ifdef VOLUMETRIC_FOG
    float jitter = blueNoise(texCoord, frameCounter);
    int steps = 24;
    float maxVolDist = min(dist, 120.0);
    float stepSize = maxVolDist / float(steps);

    for(int i = 0; i < steps; i++) {
        float d = (float(i) + jitter) * stepSize;
        vec3 pView = viewDir * d;
        vec3 pWorld = (gbufferModelViewInverse * vec4(pView, 1.0)).xyz;

        float shadow = getShadow(pWorld);
        float density = exp(-pWorld.y * 0.05) * 0.02;
        volumetric += scattering * density * shadow;
    }
    volumetric /= float(steps);
    #endif

    outColor = vec4(color + scattering + volumetric * 5.0, 1.0);
    outVolumetric = vec4(volumetric, 1.0);
}

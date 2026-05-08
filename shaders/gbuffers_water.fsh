#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/settings.glsl"
#include "/lib/surface/materials.glsl"
#include "/lib/water.glsl"

in vec2 texCoord;
in vec2 lmCoord;
in vec4 color;
in vec3 normal;
in vec3 viewPos;
in vec3 worldPos;

/* DRAWBUFFERS:014 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outData;
layout(location = 2) out vec4 outTranslucent;

uniform sampler2D texture;
uniform float frameTimeCounter;

void main() {
    vec3 animatedNormal = getWaterNormal(worldPos, frameTimeCounter);
    animatedNormal = normalize(mix(normal, animatedNormal, 0.5));

    vec4 albedo = texture2D(texture, texCoord) * color;

    outColor = albedo;
    outData = vec4(animatedNormal * 0.5 + 0.5, 0.05);
    outTranslucent = vec4(albedo.rgb, 0.5);
}

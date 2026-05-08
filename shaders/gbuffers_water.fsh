#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

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
    // Procedural Waves Normal
    vec3 animatedNormal = normal;
    float wave = sin(worldPos.x * 2.0 + frameTimeCounter) * 0.1;
    wave += cos(worldPos.z * 2.0 - frameTimeCounter * 1.5) * 0.1;
    animatedNormal = normalize(normal + vec3(wave, 0.0, wave));

    vec4 albedo = texture2D(texture, texCoord) * color;

    outColor = albedo;
    outData = vec4(animatedNormal * 0.5 + 0.5, 0.05); // Smooth water (low roughness)
    outTranslucent = vec4(albedo.rgb, 0.5); // Fixed opacity for absorption logic
}

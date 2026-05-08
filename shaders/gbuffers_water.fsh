#version 330 compatibility

#include "/lib/settings.glsl"

in vec2 texCoord;
in vec2 lmCoord;
in vec4 color;
in vec3 normal;
in vec3 viewPos;
in vec3 worldPos;

/* DRAWBUFFERS:014 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outData;
layout(location = 2) out vec4 outTranslucent; // For separate translucency pass if needed

uniform sampler2D texture;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;

    outColor = albedo;
    outData = vec4(normal * 0.5 + 0.5, 0.9); // Water is smooth
    outTranslucent = albedo;
}

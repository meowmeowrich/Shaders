#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/material.glsl"

in vec2 texCoord;
in vec2 lmCoord;
in vec4 color;
in vec3 normal;
in vec3 viewPos;
in float blockId;

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outData; // Normals(RGB), Roughness(A)

uniform sampler2D texture;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.1) discard;

    Material mat = getMaterial(albedo.rgb, blockId, texCoord);

    outColor = vec4(albedo.rgb, mat.emissive);
    outData = vec4(normal * 0.5 + 0.5, mat.roughness);
}

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
layout(location = 1) out vec4 outData; // Normals and Material Info

uniform sampler2D texture;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.1) discard;

    Material mat = getMaterial(albedo.rgb, blockId);

    outColor = albedo;

    // Encode normals in -1 to 1 range into 0 to 1 range
    // outData.rgb = normal * 0.5 + 0.5;
    // outData.a = mat.smoothness;
    outData = vec4(normal * 0.5 + 0.5, mat.smoothness);
}

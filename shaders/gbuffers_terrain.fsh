#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/settings.glsl"
#include "/lib/surface/materials.glsl"

in vec2 texCoord;
in vec2 lmCoord;
in vec4 color;
in vec3 normal;
in vec3 viewPos;
in vec3 worldPos;
in float blockId;

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outData; // Normals(RGB), Roughness(A)

uniform sampler2D texture;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color;
    if (albedo.a < 0.1) discard;

    MaterialProperties m = classifyMaterial(albedo.rgb, blockId, texCoord);

    outColor = vec4(albedo.rgb, m.emissive);
    outData = vec4(normal * 0.5 + 0.5, m.roughness);
}

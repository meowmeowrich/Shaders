#version 330 compatibility

#include "/lib/common.glsl"
#include "/lib/surface/materials.glsl"

in vec2 texCoord;
in vec2 lmCoord;
in vec4 color;
in vec3 normal;
in vec3 viewPos;

/* DRAWBUFFERS:01 */
layout(location = 0) out vec4 outColor;
layout(location = 1) out vec4 outData;

uniform sampler2D texture;
uniform vec4 entityColor;

void main() {
    vec4 albedo = texture2D(texture, texCoord) * color * entityColor;
    if (albedo.a < 0.1) discard;

    Material mat = getMaterial(albedo.rgb, 0.0, texCoord);

    outColor = vec4(albedo.rgb, mat.emissive);
    outData = vec4(normal * 0.5 + 0.5, mat.roughness);
}

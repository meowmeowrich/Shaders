#version 330 compatibility

#include "/lib/settings.glsl"
#include "/lib/core/math.glsl"
#include "/lib/lighting/brdf.glsl"

in vec2 texCoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D colortex4; // Translucency
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition;

vec3 simpleSSR(vec3 rO, vec3 rD, float jitter) {
    vec3 p = rO + rD * jitter;
    for(int i = 0; i < 16; i++) {
        vec4 proj = gbufferProjection * vec4(p, 1.0);
        vec3 screen = (proj.xyz / proj.w) * 0.5 + 0.5;
        if (screen.x < 0.0 || screen.x > 1.0 || screen.y < 0.0 || screen.y > 1.0) break;
        float d = texture2D(depthtex0, screen.xy).r;
        vec3 hitPos = screenToView(vec3(screen.xy, d), gbufferProjectionInverse);
        if (p.z < hitPos.z && length(p - hitPos) < 1.0) return texture2D(colortex0, screen.xy).rgb;
        p += rD * 1.5;
    }
    return vec3(0.0);
}

void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    float depth = texture2D(depthtex0, texCoord).r;
    vec4 data = texture2D(colortex1, texCoord);
    vec3 normal = data.rgb * 2.0 - 1.0;
    float roughness = data.a;

    if (depth < 1.0 && roughness < 0.1) {
        vec3 viewPos = screenToView(vec3(texCoord, depth), gbufferProjectionInverse);
        vec3 V = normalize(-viewPos);
        vec3 R = reflect(-V, normal);
        if (R.z < 0.0) {
            vec3 reflection = simpleSSR(viewPos, R, hash12(texCoord));
            vec3 F = F_Schlick(max(dot(normal, V), 0.0), vec3(0.04));
            color = mix(color, reflection, F * (1.0 - roughness));
        }
    }

    outColor = vec4(color, 1.0);
}

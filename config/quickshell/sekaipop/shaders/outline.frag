#version 440

// outline.frag - "character first" wallpaper transition. Port of the OUTLINE
// mode of pocket-dots' wallfx.frag (GPL-3.0, diegoMalagrida/pocket-dots) to
// SekaiPop's ShaderEffect: source1 = old wallpaper, source2 = new one (both
// already cover-cropped to the screen); fieldTex/lineTex are the maps made by
// ~/.local/bin/wallfx for the NEW image (see `wallfx cache`).
//
// The stage steps back, a thin line draws the character's outline, the
// character fills in from it, then the rest of the world spreads out of it.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;   // 0..1, linear in time
    float sw;         // screen, px
    float sh;
    float fw;         // fieldTex, texels
    float fh;
    float lw;         // lineTex, texels
    float lh;
    float lineW;      // outline width, px
    float sdRange;    // fieldTex B spans +-sdRange map px
    vec4 cropNew;     // map uv = xy + screen uv * zw (cover crop of the new image)
    vec4 ink;         // the palette's lightest tone: the outline's line
} ubuf;

layout(binding = 1) uniform sampler2D source1;   // old
layout(binding = 2) uniform sampler2D source2;   // new
layout(binding = 3) uniform sampler2D fieldTex;
layout(binding = 4) uniform sampler2D lineTex;

const float CELL = 4.0;   // px, the size of the pixels that eat through

float escena(float x) { x = clamp(x, 0.0, 1.0); return x * x * (3.0 - 2.0 * x); }
float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

vec2 cam(vec2 uv, float z) { return 0.5 + (uv - 0.5) / z; }
vec2 mapUv(vec2 uv, float z) { return ubuf.cropNew.xy + cam(uv, z) * ubuf.cropNew.zw; }

float s16(vec2 texel) {
    texel = clamp(texel, vec2(0.0), vec2(ubuf.lw, ubuf.lh) - 1.0);
    vec4 f = texture(lineTex, (texel + 0.5) / vec2(ubuf.lw, ubuf.lh));
    return (floor(f.g * 255.0 + 0.5) * 256.0 + floor(f.b * 255.0 + 0.5)) / 65535.0;
}
float surface(vec2 tuv) {
    vec2 p = tuv * vec2(ubuf.lw, ubuf.lh) - 0.5;
    vec2 i = floor(p), f = p - i;
    return mix(mix(s16(i), s16(i + vec2(1.0, 0.0)), f.x),
               mix(s16(i + vec2(0.0, 1.0)), s16(i + vec2(1.0, 1.0)), f.x), f.y);
}

void main() {
    vec2 uv = qt_TexCoord0;
    float t = clamp(ubuf.progress, 0.0, 1.0);
    float sw = ubuf.sw;

    float zCh = 1.0 + 0.03 * (1.0 - escena(t));
    float zBg = 1.0 + 0.015 * (1.0 - escena(t));
    vec4 f = texture(fieldTex, mapUv(uv, zCh));
    float sdPx = (f.b * 2.0 - 1.0) * ubuf.sdRange * sw * zCh / (ubuf.fw * ubuf.cropNew.z);
    float inside = clamp(0.5 - sdPx / max(fwidth(sdPx), 1e-3), 0.0, 1.0);

    float back = escena(t / 0.18);
    vec3 st = texture(source1, uv).rgb;
    st = mix(st, vec3(luma(st)), 0.25 * back) * (1.0 - 0.2 * back);

    vec2 grid = vec2(ubuf.sw, ubuf.sh) / CELL;
    vec2 cuv = (floor(uv * grid) + 0.5) / grid;

    float Ti = escena((t - 0.32) / 0.32) * 1.02 - 0.01;
    vec3 cIn = texture(fieldTex, mapUv(cuv, zCh)).g <= Ti ? texture(source2, cam(uv, zCh)).rgb : st;
    float To = escena((t - 0.45) / 0.50) * 1.02 - 0.01;
    vec3 cOut = surface(mapUv(cuv, zBg)) <= To ? texture(source2, cam(uv, zBg)).rgb : st;
    vec3 c = mix(cOut, cIn, inside);

    float drawP = escena((t - 0.02) / 0.33);
    float lp = texture(lineTex, mapUv(uv, zCh)).r;
    float fade = 1.0 - escena((t - 0.45) / 0.25);
    if (lp > 0.0 && lp <= drawP && fade > 0.0) {
        float d = abs(sdPx) - ubuf.lineW * 0.5;
        float core = clamp(0.5 - d / max(fwidth(sdPx), 1e-3), 0.0, 1.0);
        c = mix(c, ubuf.ink.rgb, core * 0.75 * fade);
    }
    // at t=1 hand over exactly to the new wallpaper
    if (t >= 0.999) c = texture(source2, uv).rgb;
    fragColor = vec4(clamp(c, 0.0, 1.0), 1.0) * ubuf.qt_Opacity;
}

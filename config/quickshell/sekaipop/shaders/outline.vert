#version 440

// Vertex stage for outline.frag. The uniform block MUST stay identical to the
// one in outline.frag (shaders/README.md, "Uniform layout").

layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;
layout(location = 0) out vec2 qt_TexCoord0;

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

out gl_PerVertex { vec4 gl_Position; };

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    gl_Position = ubuf.qt_Matrix * qt_Vertex;
}

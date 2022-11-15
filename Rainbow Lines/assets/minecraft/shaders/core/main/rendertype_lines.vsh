#version 150

#moj_import <vsh_util.glsl>

in vec3 Position;
in vec4 Color;
in vec3 Normal;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float LineWidth;
uniform vec2 ScreenSize;
uniform mat3 IViewRotMat;
uniform vec3 ChunkOffset;

out float vertexDistance;
out vec4 vertexColor;

out vec3 pos;

const float VIEW_SHRINK = 1.0 - (1.0 / 256.0);
const mat4 VIEW_SCALE = mat4(
    VIEW_SHRINK, 0.0, 0.0, 0.0,
    0.0, VIEW_SHRINK, 0.0, 0.0,
    0.0, 0.0, VIEW_SHRINK, 0.0,
    0.0, 0.0, 0.0, 1.0
);

void main() {
    
    pos = IViewRotMat * Position; // Translate Position to world-space
    vec4 color;
    mat4 projMat;
    float fogDistance;

    // VVVVVVVVV CODE HERE VVVVVVVVV

    color = Color;
    projMat = ProjMat;

    // Draw fog (Cylinder shape)
    fogDistance = max(
        length((ModelViewMat * vec4(pos.x, 0.0, pos.z, 1.0)).xyz),
        length((ModelViewMat * vec4(0.0, pos.y, 0.0, 1.0)).xyz));

    // Project world to screen
    gl_Position = projMat * (vec4(pos, 1.0) * mat4(IViewRotMat));

    // ^^^^^^^^^ CODE HERE ^^^^^^^^^

    vertexColor = color;

    mat4 IProjMat = inverse(projMat);
    vec4 viewPos = IProjMat * gl_Position;

    // Vanilla code
    vec4 linePosStart = projMat * VIEW_SCALE * viewPos;
    vec4 linePosEnd = projMat * VIEW_SCALE * viewPos + vec4(Normal, 1.0);

    vec3 ndc1 = linePosStart.xyz / linePosStart.w;
    vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;

    vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * ScreenSize);
    vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * LineWidth / ScreenSize;

    if (lineOffset.x < 0.0) {
        lineOffset *= -1.0;
    }

    if (gl_VertexID % 2 == 0) {
        gl_Position = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
    } else {
        gl_Position = vec4((ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
    }
}

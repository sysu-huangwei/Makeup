attribute vec2 a_position;
attribute vec2 a_texCoord;
varying vec2 texcoordOut;

void main()
{
    texcoordOut = a_texCoord;
    gl_Position = vec4(a_position, 0.0, 1.0);
}

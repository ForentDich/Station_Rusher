shader_type canvas_item;

uniform float tilt = 10.0;

void vertex() {
    VERTEX.x -= UV.y*tilt;
}
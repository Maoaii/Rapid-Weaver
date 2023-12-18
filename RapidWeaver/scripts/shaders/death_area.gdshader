shader_type canvas_item;

uniform float speed : hint_range(0, 10) = 1.0;
uniform float amplitude : hint_range(0, 20) = 0.2;
uniform float frequency : hint_range(0.1, 20) = 1.0;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
    // Calculate the wave effect based on time, vertex position, and frequency
    float wave = sin((TIME + random(vec2(1.0, 1.0))) * speed + VERTEX.x * frequency) * amplitude;

    // Offset the y-coordinate of the vertex based on the wave effect
    VERTEX.y += wave;
}
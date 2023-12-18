shader_type canvas_item;

// Uniforms
uniform float amplitude : hint_range(-100.0, 100.0) = 20.0;
uniform float frequency : hint_range(0.1, 10.0) = 1.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

void vertex() {
    // Calculate the displacement based on a sinusoidal wave
    float displacement = amplitude * sin(TIME * frequency * time_scale);
    
    // Apply the displacement to the Y coordinate of the vertex position
    VERTEX.y += displacement;
}
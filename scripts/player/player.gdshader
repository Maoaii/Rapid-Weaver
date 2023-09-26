shader_type canvas_item;

uniform bool active = false;
uniform float alpha = 1;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 white_color = vec4(1.0, 1.0, 1.0, alpha);
	vec4 new_color = previous_color;
	if (active == true)
	{
		new_color = white_color;
	}
	COLOR = new_color;
}
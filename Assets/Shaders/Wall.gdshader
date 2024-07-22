shader_type canvas_item;
 
uniform float DisappearHeight : hint_range(-1.0, 1.0) = 1.0;
uniform float DisappearWidth : hint_range(0.0, 0.5) = 0.1;
 
void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	COLOR = texture_color;
    COLOR.a = smoothstep(   1.0 - DisappearHeight - (0.5 * DisappearWidth), 
                            1.0 - DisappearHeight + (0.5 * DisappearWidth), UV.y + 0.5);
}

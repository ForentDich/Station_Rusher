shader_type canvas_item;

uniform int sheet_columns = 1;
uniform int sheet_rows = 1;
uniform float DisappearHeight : hint_range(-1.0, 1.0) = 1;
uniform float DisappearWidth : hint_range(0.0, 1.0) = 0.1;
   
void fragment() {
    vec2 sprite_sheet_size = vec2(textureSize(TEXTURE,0));
	vec2 frame_size;
	frame_size.x = sprite_sheet_size.x/float(sheet_columns);
	frame_size.y = sprite_sheet_size.y/float(sheet_rows);
	vec4 texture_color = texture(TEXTURE, UV);
	vec2 current_point = sprite_sheet_size * UV;
	float row = floor(current_point.y / frame_size.y);
	float column = floor(current_point.x / frame_size.x);
	vec2 max_point = (frame_size * vec2(column, row)) + frame_size;
	vec2 new_uv = 1.0 - (max_point - current_point) / frame_size;
	COLOR = texture_color;
    COLOR.a -= smoothstep(   1.0 - DisappearHeight + (0.5 * DisappearWidth), 
                            1.0 - DisappearHeight - (0.5 * DisappearWidth), UV.y + 0.5);
}
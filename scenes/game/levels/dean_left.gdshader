shader_type canvas_item;

uniform vec4 override_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float blend_amount : hint_range(0.0, 1.0) = 0.5;
uniform bool preserve_alpha = true;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 blended_rgb = mix(tex_color.rgb, override_color.rgb, blend_amount);
	COLOR = vec4(blended_rgb, preserve_alpha ? tex_color.a : override_color.a);
}

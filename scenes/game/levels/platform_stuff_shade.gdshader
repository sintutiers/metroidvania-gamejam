shader_type canvas_item;

uniform vec4 platform_tint : source_color = vec4(1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_pulse_speed : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float glow_strength : hint_range(0.0, 2.0, 0.01) = 0.3;
uniform float edge_softness : hint_range(0.01, 0.5, 0.005) = 0.05;

uniform float dissolve_amount : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec4 dissolve_edge_color : source_color = vec4(1.0, 0.6, 0.1, 1.0);
uniform float dissolve_edge_width : hint_range(0.0, 0.3, 0.005) = 0.05;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // pulsing edge glow (distance to nearest UV border)
    vec2 edge_dist = min(UV, 1.0 - UV);
    float edge_factor = 1.0 - smoothstep(0.0, edge_softness, min(edge_dist.x, edge_dist.y));
    float pulse = 0.5 + 0.5 * sin(TIME * glow_pulse_speed);
    vec3 glow = glow_color.rgb * edge_factor * glow_strength * pulse;

    // dissolve: static per-pixel noise threshold cut, with a colored edge band
    float noise_value = hash(floor(UV * 64.0));
    float dissolve_cut = step(dissolve_amount, noise_value);
    float dissolve_edge = step(dissolve_amount, noise_value) *
        (1.0 - step(dissolve_amount + dissolve_edge_width, noise_value));

    vec3 final_rgb = tex_color.rgb * platform_tint.rgb + glow;
    final_rgb = mix(final_rgb, dissolve_edge_color.rgb, dissolve_edge);

    COLOR = vec4(final_rgb, tex_color.a * platform_tint.a * dissolve_cut);
}
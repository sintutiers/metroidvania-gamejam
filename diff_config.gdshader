shader_type canvas_item;

uniform vec4 portal_tint : source_color = vec4(1.0);

uniform float vortex_effect_radius : hint_range(0.01, 1.0, 0.01) = 1;
uniform float twist_strength : hint_range(0.0, 30.0, 0.1) = 0.0;

uniform float pulsation_speed : hint_range(0.0, 5.0, 0.01) = 0.0;
uniform float breath_magnitude : hint_range(-0.3, 0.3, 0.005) = 0.0;

uniform float overall_rotation_speed : hint_range(-2.0, 2.0, 0.01) = 0.0;

uniform float texture_scroll_speed_x : hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float texture_scroll_speed_y : hint_range(-1.0, 1.0, 0.01) = 0.0;

uniform float edge_softness : hint_range(0.01, 0.5, 0.005) = 0.01;

void fragment() {
    float aspect = TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
    vec2 uv = UV - 0.5;

    if (aspect < 1.0) {
        uv.x /= aspect;
    } else {
        uv.y *= aspect;
    }

    float time_progress = sin(TIME * pulsation_speed);
    float distance_from_center = length(uv);

    float twist_factor = smoothstep(
        0.0,
        vortex_effect_radius,
        vortex_effect_radius - distance_from_center
    );

    float twist_angle =
        twist_factor *
        twist_strength *
        time_progress;

    float total_rotation =
        TIME * overall_rotation_speed +
        twist_angle;

    float s = sin(total_rotation);
    float c = cos(total_rotation);

    uv = mat2(
        vec2(c, -s),
        vec2(s, c)
    ) * uv;

    float new_distance = max(
        0.0,
        distance_from_center +
        breath_magnitude * time_progress
    );

    uv *= new_distance / max(distance_from_center, 0.0001);

    uv += TIME * vec2(
        texture_scroll_speed_x,
        texture_scroll_speed_y
    );

    if (aspect < 1.0) {
        uv.x *= aspect;
    } else {
        uv.y /= aspect;
    }

    vec2 final_uv = uv + 0.5;

    // hard guarantee: sample coordinate can never leave [0,1], regardless
    // of stretch, aspect mismatch, or any warp parameter combination
    vec2 clamped_uv = clamp(final_uv, 0.0, 1.0);

    // fade out before hitting the clamp, so it's a soft edge, not a hard cut
    vec2 boundary_dist = min(final_uv, 1.0 - final_uv);
    float boundary_mask = smoothstep(0.0, edge_softness, min(boundary_dist.x, boundary_dist.y));

    float vortex_alpha = smoothstep(
        vortex_effect_radius,
        vortex_effect_radius - edge_softness,
        distance_from_center
    );

    vec4 texture_color = texture(
        TEXTURE,
        clamped_uv
    );

    COLOR = texture_color * portal_tint;
    COLOR.a *= vortex_alpha * boundary_mask;
}
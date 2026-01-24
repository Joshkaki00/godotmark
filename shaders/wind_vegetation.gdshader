shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;

uniform float wind_strength : hint_range(0.0, 1.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.5);

void vertex() {
	// Wind animation based on vertex height (top of plants sway more)
	float height_factor = UV.y; // 0 at base, 1 at top
	
	vec2 wind_offset = wind_direction * sin(TIME * wind_speed + VERTEX.x + VERTEX.z) * wind_strength;
	VERTEX.x += wind_offset.x * height_factor;
	VERTEX.z += wind_offset.y * height_factor;
}

void fragment() {
	// Standard PBR material
	ALBEDO = texture(albedo_texture, UV).rgb;
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	ROUGHNESS = texture(roughness_texture, UV).r;
	METALLIC = 0.0;
}

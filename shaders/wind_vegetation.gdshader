shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture : hint_default_white;

uniform float wind_strength : hint_range(0.0, 1.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float turbulence : hint_range(0.0, 1.0) = 0.2;

void vertex() {
	// Wind animation based on vertex height (top of plants sway more)
	float height_factor = UV.y; // 0 at base, 1 at top
	
	// Main wind wave
	float wind_wave = sin(TIME * wind_speed + VERTEX.x * 0.5 + VERTEX.z * 0.5);
	
	// Add turbulence for natural movement
	float turbulence_wave = sin(TIME * wind_speed * 2.3 + VERTEX.x * 1.7) * turbulence;
	
	vec2 wind_offset = wind_direction * (wind_wave + turbulence_wave) * wind_strength;
	
	VERTEX.x += wind_offset.x * height_factor;
	VERTEX.z += wind_offset.y * height_factor;
}

void fragment() {
	// Standard PBR with textures
	vec4 albedo_tex = texture(albedo_texture, UV);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
	
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	ROUGHNESS = texture(roughness_texture, UV).r;
	METALLIC = 0.0;
}

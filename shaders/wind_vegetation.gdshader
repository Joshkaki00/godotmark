shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

// Wind animation parameters (faster, smaller motion for vegetation)
uniform float wind_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.15;
uniform float max_height : hint_range(0.5, 5.0) = 2.0;

// Material parameters (to preserve textures from GLTF)
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color;
uniform bool use_texture = false;

void vertex() {
	// Height-based wind (stronger at top)
	float height_factor = VERTEX.y / max_height;
	height_factor = max(0.0, height_factor);
	
	// Per-instance variation using INSTANCE_ID
	float instance_offset = float(INSTANCE_ID) * 0.314159;
	
	// Fast, subtle wind sway for small vegetation
	float wind_x = sin(TIME * wind_speed + instance_offset + VERTEX.x);
	float wind_z = cos(TIME * wind_speed * 0.7 + instance_offset + VERTEX.z);
	
	// Apply wind displacement (subtle for vegetation)
	VERTEX.x += wind_x * wind_strength * height_factor;
	VERTEX.z += wind_z * wind_strength * 0.6 * height_factor;
}

void fragment() {
	// Apply albedo color and texture if available
	vec4 albedo = albedo_color;
	if (use_texture) {
		albedo *= texture(albedo_texture, UV);
	}
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
	
	// Per-vertex lighting is applied automatically by render_mode diffuse_lambert
}

shader_type spatial;

// Wind animation parameters (slower, larger motion for trees)
uniform float wind_speed : hint_range(0.0, 5.0) = 0.8;
uniform float wind_strength : hint_range(0.0, 1.0) = 0.4;
uniform float max_height : hint_range(1.0, 20.0) = 5.0;

// Material parameters (to preserve textures from GLTF)
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color;
uniform bool use_texture = false;

void vertex() {
	// Height-based wind (stronger at top - tree canopy sways more)
	float height_factor = VERTEX.y / max_height;
	height_factor = max(0.0, height_factor);
	
	// Per-instance variation using INSTANCE_ID
	float instance_offset = float(INSTANCE_ID) * 0.314159;
	
	// Slower, more dramatic wind sway for trees
	float wind_x = sin(TIME * wind_speed + instance_offset + VERTEX.x * 0.5);
	float wind_z = cos(TIME * wind_speed * 0.7 + instance_offset + VERTEX.z * 0.5);
	
	// Apply wind displacement (much stronger at top for dramatic canopy motion)
	VERTEX.x += wind_x * wind_strength * height_factor;
	VERTEX.z += wind_z * wind_strength * 0.6 * height_factor;
	
	// Add slight pivot/tilt at base for more natural motion
	float pivot_factor = height_factor * 0.3;
	VERTEX.x += sin(TIME * wind_speed * 0.5 + instance_offset) * pivot_factor;
}

void fragment() {
	// Apply albedo color and texture if available
	vec4 albedo = albedo_color;
	if (use_texture) {
		albedo *= texture(albedo_texture, UV);
	}
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}

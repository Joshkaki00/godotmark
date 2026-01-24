shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.05, 0.25, 0.35, 0.85);
uniform vec4 shallow_color : source_color = vec4(0.2, 0.5, 0.6, 0.7);
uniform float wave_speed : hint_range(0.0, 2.0) = 0.4;
uniform float wave_height : hint_range(0.0, 0.2) = 0.03;
uniform float wave_frequency : hint_range(1.0, 10.0) = 4.0;
uniform float foam_edge_distance : hint_range(0.0, 2.0) = 0.5;

void vertex() {
	// Animated waves using multiple sine waves
	float wave1 = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * 0.5;
	float wave2 = cos(VERTEX.z * wave_frequency * 0.8 + TIME * wave_speed * 1.3) * 0.5;
	
	VERTEX.y += (wave1 + wave2) * wave_height;
}

void fragment() {
	// Calculate distance from shore (based on Z position)
	// Assumes beach is at higher Z values
	float depth_factor = smoothstep(0.0, foam_edge_distance, -VERTEX.z);
	
	// Mix shallow and deep colors
	vec3 color = mix(shallow_color.rgb, water_color.rgb, depth_factor);
	float alpha = mix(shallow_color.a, water_color.a, depth_factor);
	
	ALBEDO = color;
	ALPHA = alpha;
	
	ROUGHNESS = 0.08;
	METALLIC = 0.4;
	SPECULAR = 0.9;
}

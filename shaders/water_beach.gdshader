shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, specular_schlick_ggx;

uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.4, 0.8);
uniform vec4 shallow_color : source_color = vec4(0.3, 0.6, 0.7, 0.6);
uniform float wave_speed : hint_range(0.0, 2.0) = 0.5;
uniform float wave_height : hint_range(0.0, 0.5) = 0.05;
uniform float wave_frequency : hint_range(1.0, 10.0) = 3.0;

void vertex() {
	// Animated waves
	float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * 
	             cos(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 1.3);
	VERTEX.y += wave * wave_height;
}

void fragment() {
	// Depth-based color mixing
	float depth = 1.0 - VERTEX.y;
	ALBEDO = mix(shallow_color.rgb, water_color.rgb, depth);
	ALPHA = mix(shallow_color.a, water_color.a, depth);
	
	ROUGHNESS = 0.1;
	METALLIC = 0.3;
	SPECULAR = 0.8;
}

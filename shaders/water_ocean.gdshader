shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Phase control (1-5)
uniform int phase = 1;

// Water color
uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 0.9);
uniform vec4 deep_water_color : source_color = vec4(0.0, 0.1, 0.3, 1.0);

// Wave parameters
uniform float wave_speed = 0.5;
uniform float wave_height = 0.0;
uniform float wave_frequency = 1.0;

// Foam parameters
uniform float foam_amount = 0.0;
uniform float foam_cutoff = 0.5;

// Reflection/refraction (Phase 5)
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Phase 1-2: Just UV scroll
	UV += vec2(TIME * wave_speed * 0.05, TIME * wave_speed * 0.03);
	
	// Phase 2+: Add wave displacement
	if (phase >= 2 && wave_height > 0.0) {
		float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) 
		           + cos(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 0.8);
		VERTEX.y += wave * wave_height;
	}
}

void fragment() {
	// Base water color (gradient based on depth/distance)
	vec3 color = mix(water_color.rgb, deep_water_color.rgb, UV.y);
	
	// Phase 3+: Add foam at shore/peaks
	if (phase >= 3 && foam_amount > 0.0) {
		float foam_noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
		if (foam_noise > foam_cutoff) {
			color = mix(color, vec3(1.0), foam_amount);
		}
	}
	
	ALBEDO = color;
	
	// Phase 4+: Enhanced lighting
	if (phase >= 4) {
		ROUGHNESS = roughness;
		METALLIC = metallic;
		SPECULAR = 0.5;
	} else {
		// Phase 1-3: Unshaded/simple
		ROUGHNESS = 1.0;
		METALLIC = 0.0;
		SPECULAR = 0.0;
	}
	
	ALPHA = water_color.a;
}

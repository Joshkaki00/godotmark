shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_disabled;

// RASPBERRY PI OPTIMIZED OCEAN SHADER
// - NO fragment shader math (per-pixel calculations are death on mobile GPUs)
// - Vertex displacement only (VideoCore VII is good at vertex processing)
// - Simple UV scrolling for visual interest
// - Pre-baked foam texture (no procedural noise)

// Phase control (1-5)
uniform int phase = 1;

// Water color
uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.5, 0.9);

// Wave parameters (vertex displacement only)
uniform float wave_speed = 0.5;
uniform float wave_height = 0.0;
uniform float wave_frequency = 1.0;

// Optional foam texture (pre-baked, not procedural)
uniform sampler2D foam_texture : hint_default_white;
uniform float foam_scroll_speed = 0.2;

void vertex() {
	// Simple UV scrolling for visual interest
	UV += vec2(TIME * wave_speed * 0.05, TIME * wave_speed * 0.03);
	
	// Phase 4+: Add vertex wave displacement (cheap on VideoCore VII)
	if (phase >= 4 && wave_height > 0.0) {
		float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) 
		           + cos(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 0.8);
		VERTEX.y += wave * wave_height;
	}
}

void fragment() {
	// SIMPLE: Just output the water color (no per-pixel math!)
	ALBEDO = water_color.rgb;
	
	// Phase 5: Optional foam texture (if provided)
	// NOTE: This is still per-pixel, but texture sampling is cheap on mobile GPUs
	if (phase >= 5) {
		vec2 foam_uv = UV + vec2(TIME * foam_scroll_speed, 0.0);
		vec3 foam = texture(foam_texture, foam_uv).rgb;
		ALBEDO = mix(ALBEDO, foam, 0.1);  // Very subtle foam overlay
	}
	
	// Simple per-vertex lighting (handled by render_mode)
	ROUGHNESS = 0.3;
	METALLIC = 0.0;
	SPECULAR = 0.0;  // Disabled for performance
	
	ALPHA = water_color.a;
}

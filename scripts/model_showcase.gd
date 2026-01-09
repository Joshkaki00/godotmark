extends Node3D
## 1-Minute Model Showcase - Progressive GPU Stress Test
## Synced to "Excelsior In Aeternum.ogg" (60 seconds)

@onready var bust = $MarbleBust
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var env = $WorldEnvironment
@onready var particles = $Particles
@onready var audio = $AudioStreamPlayer
@onready var fade_overlay = $FadeOverlay

# Performance monitoring
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager
var current_quality_preset = 2  # Default to Medium

# Timeline tracking
var timeline = 0.0
var phase = 0
var phase_triggered = [false, false, false, false, false, false, false]
var fade_started = false

# Performance metrics
var metrics = {
	"phase_1": {"fps": [], "frame_times": [], "temps": []},
	"phase_2": {"fps": [], "frame_times": [], "temps": []},
	"phase_3": {"fps": [], "frame_times": [], "temps": []},
	"phase_4": {"fps": [], "frame_times": [], "temps": []},
	"phase_5": {"fps": [], "frame_times": [], "temps": []}
}

var current_phase_key = "phase_1"

func _ready():
	print("\n========================================")
	print("[ModelShowcase] Starting 1-Minute Benchmark")
	print("========================================\n")
	
	# Get performance systems from main scene if available
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		perf_monitor = main.perf_monitor
		quality_manager = main.quality_manager
		if quality_manager:
			current_quality_preset = quality_manager.get_quality_preset()
			print("[ModelShowcase] Quality preset: ", quality_manager.get_quality_name())
	
	# Setup initial phase
	setup_phase_1()
	
	# Start audio
	audio.play()
	print("[ModelShowcase] Audio started - 60 second timer begins")

func _process(delta):
	timeline += delta
	
	# Collect metrics
	if perf_monitor:
		var fps = perf_monitor.get_avg_fps()
		var frame_time = perf_monitor.get_current_frametime_ms()
		var temp = perf_monitor.get_temperature()
		
		metrics[current_phase_key]["fps"].append(fps)
		metrics[current_phase_key]["frame_times"].append(frame_time)
		metrics[current_phase_key]["temps"].append(temp)
	
	# Fade to black at 55 seconds (song fades out)
	if timeline >= 55.0 and not fade_started:
		fade_started = true
		start_fadeout()
	
	# Update fade overlay
	if fade_started and timeline < 60.0:
		var fade_progress = (timeline - 55.0) / 5.0  # 5 second fade
		if fade_overlay:
			fade_overlay.color.a = fade_progress
	
	# Phase transitions (12-second intervals)
	if timeline >= 12.0 and not phase_triggered[1]:
		phase_triggered[1] = true
		phase = 2
		current_phase_key = "phase_2"
		transition_to_phase_2()
	elif timeline >= 24.0 and not phase_triggered[2]:
		phase_triggered[2] = true
		phase = 3
		current_phase_key = "phase_3"
		transition_to_phase_3()
	elif timeline >= 36.0 and not phase_triggered[3]:
		phase_triggered[3] = true
		phase = 4
		current_phase_key = "phase_4"
		transition_to_phase_4()
	elif timeline >= 48.0 and not phase_triggered[4]:
		phase_triggered[4] = true
		phase = 5
		current_phase_key = "phase_5"
		transition_to_phase_5()
	elif timeline >= 60.0 and not phase_triggered[5]:
		phase_triggered[5] = true
		finish_showcase()

func setup_phase_1():
	print("\n[Phase 1] Basic PBR (0-12s)")
	print("  - No shadows, no HDR, no post-processing")
	
	# Disable all advanced features
	light.shadow_enabled = false
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.1, 0.1, 0.12)
	env.environment.glow_enabled = false
	env.environment.ssao_enabled = false
	env.environment.ssr_enabled = false
	particles.emitting = false
	
	# Ensure bust is visible
	if bust:
		bust.visible = true

func transition_to_phase_2():
	print("\n[Phase 2] HDR Lighting + Shadows (12-24s)")
	print("  - Enabling HDR environment and shadow casting")
	
	# Enable shadows
	light.shadow_enabled = true
	light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	
	# Load HDR environment
	var hdr_path = "res://art/model-test/sunflowers_puresky_2k.hdr"
	if ResourceLoader.exists(hdr_path):
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = load(hdr_path)
		sky.sky_material = sky_material
		env.environment.background_mode = Environment.BG_SKY
		env.environment.sky = sky
		print("  ✓ HDR environment loaded")
	else:
		print("  ⚠ HDR not found, using color background")

func transition_to_phase_3():
	print("\n[Phase 3] Enhanced Materials + Reflections (24-36s)")
	
	# Only enable advanced features for Low+ quality
	if current_quality_preset >= 1:  # Low or higher
		print("  - Enabling SSR and SSAO")
		
		# Enable screen-space reflections
		env.environment.ssr_enabled = true
		env.environment.ssr_max_steps = 64
		env.environment.ssr_fade_in = 0.15
		env.environment.ssr_fade_out = 2.0
		
		# Enable ambient occlusion
		env.environment.ssao_enabled = true
		env.environment.ssao_radius = 2.0
		env.environment.ssao_intensity = 2.0
		env.environment.ssao_detail = 0.5
		
		print("  ✓ SSR and SSAO enabled")
	else:
		print("  - Skipped (Potato quality)")

func transition_to_phase_4():
	print("\n[Phase 4] Particles + Glow (36-48s)")
	
	# Only enable for Medium+ quality
	if current_quality_preset >= 2:  # Medium or higher
		print("  - Enabling particles and bloom")
		
		# Enable glow/bloom (push intensity!)
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 0.7  # Increased from 0.5
		env.environment.glow_bloom = 0.15  # Increased from 0.1
		env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
		
		# Create particle material if needed
		if particles.process_material == null:
			var particle_mat = ParticleProcessMaterial.new()
			particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			particle_mat.emission_sphere_radius = 2.0
			particle_mat.direction = Vector3(0, 1, 0)
			particle_mat.spread = 45.0
			particle_mat.initial_velocity_min = 0.5
			particle_mat.initial_velocity_max = 1.5
			particle_mat.gravity = Vector3(0, -0.5, 0)
			particle_mat.scale_min = 0.02
			particle_mat.scale_max = 0.05
			particles.process_material = particle_mat
		
		# Add draw mesh for particles (this is what was missing!)
		if particles.draw_pass_1 == null:
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.02
			sphere_mesh.height = 0.04
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(1, 1, 0.9, 0.8)  # Warm white, slightly transparent
			material.emission_enabled = true
			material.emission = Color(1, 0.95, 0.8)
			material.emission_energy_multiplier = 2.0
			sphere_mesh.material = material
			particles.draw_pass_1 = sphere_mesh
		
		# Enable particles with quality-based count (push limits!)
		var particle_count = 2000  # Medium default: push to 2000
		if quality_manager:
			particle_count = quality_manager.get_particle_count()
		particles.amount = particle_count  # Use full quality count
		particles.emitting = true
		
		print("  ✓ Particles (%d) and glow enabled" % particles.amount)
	else:
		print("  - Skipped (Low/Potato quality)")

func start_fadeout():
	print("\n[Phase 5.5] Fade to Black (55-60s)")
	print("  - Syncing with audio fade-out")

func transition_to_phase_5():
	print("\n[Phase 5] Maximum Complexity (48-60s)")
	
	# Only enable for High+ quality
	if current_quality_preset >= 3:  # High or higher
		print("  - Maximum effects and particle count")
		
		# Increase glow intensity (push to maximum!)
		if env.environment.glow_enabled:
			env.environment.glow_intensity = 1.0  # Maximum
			env.environment.glow_bloom = 0.2  # Increased
		
		# Increase particle count based on quality (push to max!)
		if particles.emitting:
			var particle_count = 5000  # High default: push to 5000
			if quality_manager:
				particle_count = quality_manager.get_particle_count()
			particles.amount = particle_count  # Use full quality count
			print("  ✓ Particle count increased to %d" % particles.amount)
		
		# Add depth of field
		if camera.attributes == null:
			var cam_attr = CameraAttributesPractical.new()
			cam_attr.dof_blur_far_enabled = true
			cam_attr.dof_blur_far_distance = 8.0
			cam_attr.dof_blur_far_transition = 2.0
			camera.attributes = cam_attr
		else:
			if camera.attributes is CameraAttributesPractical:
				camera.attributes.dof_blur_far_enabled = true
				camera.attributes.dof_blur_far_distance = 8.0
				camera.attributes.dof_blur_far_transition = 2.0
		
		print("  ✓ Maximum effects enabled")
	else:
		print("  - Reduced effects (Medium/Low/Potato quality)")

func finish_showcase():
	print("\n========================================")
	print("[ModelShowcase] Benchmark Complete!")
	print("========================================\n")
	
	# Calculate and print results
	print_phase_results()
	
	# Export results to JSON
	export_results()
	
	# Stop audio
	audio.stop()

func print_phase_results():
	print("Performance Summary:")
	print("-------------------")
	
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5"]:
		var fps_data = metrics[phase_key]["fps"]
		if fps_data.size() > 0:
			var avg_fps = 0.0
			var min_fps = 999.0
			var max_fps = 0.0
			
			for fps in fps_data:
				avg_fps += fps
				min_fps = min(min_fps, fps)
				max_fps = max(max_fps, fps)
			
			avg_fps /= fps_data.size()
			
			var phase_num = phase_key.substr(6, 1)
			print("Phase %s: Avg %.1f FPS (min: %.1f, max: %.1f)" % [phase_num, avg_fps, min_fps, max_fps])

func export_results():
	var results = {
		"benchmark": "Model Showcase",
		"duration": 60.0,
		"timestamp": Time.get_datetime_string_from_system(),
		"phases": {}
	}
	
	# Process each phase
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5"]:
		var fps_data = metrics[phase_key]["fps"]
		var frame_time_data = metrics[phase_key]["frame_times"]
		var temp_data = metrics[phase_key]["temps"]
		
		if fps_data.size() > 0:
			var avg_fps = 0.0
			var min_fps = 999.0
			var max_fps = 0.0
			var avg_frame_time = 0.0
			var avg_temp = 0.0
			
			for i in fps_data.size():
				avg_fps += fps_data[i]
				min_fps = min(min_fps, fps_data[i])
				max_fps = max(max_fps, fps_data[i])
				if i < frame_time_data.size():
					avg_frame_time += frame_time_data[i]
				if i < temp_data.size():
					avg_temp += temp_data[i]
			
			avg_fps /= fps_data.size()
			avg_frame_time /= frame_time_data.size() if frame_time_data.size() > 0 else 1
			avg_temp /= temp_data.size() if temp_data.size() > 0 else 1
			
			results["phases"][phase_key] = {
				"avg_fps": avg_fps,
				"min_fps": min_fps,
				"max_fps": max_fps,
				"avg_frame_time_ms": avg_frame_time,
				"avg_temperature": avg_temp
			}
	
	# Save to file
	var file = FileAccess.open("user://model_showcase_results.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(results, "\t"))
		file.close()
		print("\n✓ Results exported to: user://model_showcase_results.json")
		print("  (Location: %s)" % OS.get_user_data_dir())
	else:
		print("\n✗ Failed to export results")

func _input(event):
	# Allow ESC to exit early
	if event.is_action_pressed("ui_cancel"):
		print("\n[ModelShowcase] Cancelled by user")
		get_tree().change_scene_to_file("res://scenes/main.tscn")


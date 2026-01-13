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
@onready var metrics_overlay = $MetricsOverlay

# Performance monitoring
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager
var platform_detector  # Get from main scene
var current_quality_preset = 2  # Default to Medium

# Timeline tracking
var timeline = 0.0
var phase = 0
var phase_triggered = [false, false, false, false, false, false, false]
var fade_started = false

# Particle optimization
var particle_lod_enabled = true
var max_safe_particles = {
	0: 100,   # Potato: very few
	1: 500,   # Low: minimal
	2: 1000,  # Medium: reduced from 2000
	3: 2000,  # High: reduced from 5000
	4: 3000   # Ultra: capped for stability
}

# Enhanced performance metrics with CPU, GPU and timestamps
var metrics = {}

var current_phase_key = "phase_1"

# Per-second aggregated data
var per_second_metrics = []
var current_second_data = {}
var last_second_mark = 0.0

# Memory optimization: track indices instead of using append
var phase_sample_indices = {}
var second_sample_index = 0

# Memory diagnostics
var frame_count = 0
var last_memory_report = 0.0

func _ready():
	print("\n========================================")
	print("[ModelShowcase] Starting 1-Minute Benchmark")
	print("========================================\n")
	
	# Get performance systems from main scene if available
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		perf_monitor = main.perf_monitor
		quality_manager = main.quality_manager
		platform_detector = main.platform_detector
		print("[ModelShowcase] Systems found: perf=%s, quality=%s, platform=%s" % [
			perf_monitor != null, quality_manager != null, platform_detector != null
		])
		if quality_manager:
			current_quality_preset = quality_manager.get_quality_preset()
			print("[ModelShowcase] Quality preset: ", quality_manager.get_quality_name())
	else:
		print("[ModelShowcase] WARNING: Main scene not found, using Engine fallback")
		# PerformanceMonitor disabled - causes resource spikes
		# Will use Engine.get_frames_per_second() fallback
		perf_monitor = null
		platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		print("[ModelShowcase] Standalone systems created (Engine fallback mode)")
	
	# Pre-allocate all arrays to prevent GC pauses during benchmark
	print("[ModelShowcase] Pre-allocating arrays for optimal performance...")
	var expected_samples = 720  # 12 seconds per phase @ 60 FPS
	
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5"]:
		metrics[phase_key] = {
			"fps": [],
			"frame_times": [],
			"cpu": [],
			"temps": [],
			"gpu": [],
			"timestamps": []
		}
		# Pre-allocate capacity
		metrics[phase_key]["fps"].resize(expected_samples)
		metrics[phase_key]["frame_times"].resize(expected_samples)
		metrics[phase_key]["cpu"].resize(expected_samples)
		metrics[phase_key]["temps"].resize(expected_samples)
		metrics[phase_key]["gpu"].resize(expected_samples)
		metrics[phase_key]["timestamps"].resize(expected_samples)
		
		# Reset to 0 size but keep capacity
		metrics[phase_key]["fps"].clear()
		metrics[phase_key]["frame_times"].clear()
		metrics[phase_key]["cpu"].clear()
		metrics[phase_key]["temps"].clear()
		metrics[phase_key]["gpu"].clear()
		metrics[phase_key]["timestamps"].clear()
		
		# Initialize sample indices
		phase_sample_indices[phase_key] = 0
	
	# Pre-allocate per-second arrays (60 FPS = 60 samples per second)
	current_second_data = {
		"fps": [],
		"frame_times": [],
		"cpu": [],
		"temps": [],
		"gpu": []
	}
	for key in current_second_data.keys():
		current_second_data[key].resize(60)
		current_second_data[key].clear()
	
	# Pre-allocate per_second_metrics (60 seconds)
	per_second_metrics.resize(60)
	per_second_metrics.clear()
	
	print("[ModelShowcase] Array pre-allocation complete")
	
	# Comprehensive shader pre-warming to eliminate first-frame spikes
	print("[ModelShowcase] Pre-warming shaders and effects...")
	await get_tree().process_frame
	
	if env and env.environment:
		# Enable all effects that will be used during benchmark
		var original_glow = env.environment.glow_enabled
		var original_ssr = env.environment.ssr_enabled
		var original_ssao = env.environment.ssao_enabled
		
		# Enable glow (used in phase 4-5)
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 1.0
		env.environment.glow_bloom = 0.2
		await get_tree().process_frame
		
		# Enable SSR (used in phase 3-5)
		env.environment.ssr_enabled = true
		await get_tree().process_frame
		
		# Enable SSAO (used in phase 3-5)
		env.environment.ssao_enabled = true
		await get_tree().process_frame
		
		# Enable shadows (used in phase 2-5)
		if light:
			light.shadow_enabled = true
			await get_tree().process_frame
			light.shadow_enabled = false
		
		# Restore original states
		env.environment.glow_enabled = original_glow
		env.environment.ssr_enabled = original_ssr
		env.environment.ssao_enabled = original_ssao
	
	print("[ModelShowcase] Shader pre-warming complete (all effects)")
	
	# Pre-load HDR texture to prevent phase 2 loading spike
	print("[ModelShowcase] Pre-loading HDR environment...")
	var hdr_path = "res://art/model-test/sunflowers_puresky_2k.hdr"
	if ResourceLoader.exists(hdr_path):
		var hdr_texture = load(hdr_path)
		# Texture is now cached, won't cause spike in phase 2
		print("[ModelShowcase] HDR pre-loaded successfully")
	else:
		print("[ModelShowcase] WARNING: HDR texture not found")
	
	# Setup initial phase
	setup_phase_1()
	
	# Initialize metrics overlay
	if metrics_overlay:
		metrics_overlay.update_phase(1, "Basic PBR")
	
	# Start audio
	audio.play()
	print("[ModelShowcase] Audio started - 60 second timer begins")

func _process(delta):
	timeline += delta
	frame_count += 1
	
	# PerformanceMonitor disabled - using Engine fallback
	# No update needed
	
	# Collect comprehensive metrics
	var fps = 0.0
	var frame_time = 0.0
	var cpu_usage = 0.0
	var temp = 0.0
	var gpu_usage = 0.0
	
	if perf_monitor:
		fps = perf_monitor.get_avg_fps()
		frame_time = perf_monitor.get_current_frametime_ms()
		cpu_usage = perf_monitor.get_cpu_usage()
		temp = perf_monitor.get_temperature()
		gpu_usage = perf_monitor.get_gpu_usage()  # 0-100
	else:
		# Fallback: use Engine metrics
		fps = Engine.get_frames_per_second()
		frame_time = 1000.0 / fps if fps > 0 else 0.0
		cpu_usage = 0.0  # Not available
		temp = 0.0  # Not available
		gpu_usage = 0.0  # Not available
	
	# Skip metrics collection for first 2 seconds (warmup period)
	if timeline >= 2.0:
		# Per-frame data (use push_back on pre-allocated arrays)
		metrics[current_phase_key]["fps"].push_back(fps)
		metrics[current_phase_key]["frame_times"].push_back(frame_time)
		metrics[current_phase_key]["cpu"].push_back(cpu_usage)
		metrics[current_phase_key]["temps"].push_back(temp)
		metrics[current_phase_key]["gpu"].push_back(gpu_usage)
		metrics[current_phase_key]["timestamps"].push_back(timeline)
		
		# Per-second aggregation (use push_back on pre-allocated arrays)
		current_second_data["fps"].push_back(fps)
		current_second_data["frame_times"].push_back(frame_time)
		current_second_data["cpu"].push_back(cpu_usage)
		current_second_data["temps"].push_back(temp)
		current_second_data["gpu"].push_back(gpu_usage)
	
	if timeline - last_second_mark >= 1.0:
		aggregate_second_data()
		last_second_mark = timeline
	
	# Report memory usage every 15 seconds (reduced frequency)
	if timeline - last_memory_report >= 15.0:
		var mem_static = Performance.get_monitor(Performance.MEMORY_STATIC_MAX)
		print("[Memory] Static: %.2f MB, Frame: %d" % [
			mem_static / 1048576.0,
			frame_count
		])
		last_memory_report = timeline
	
	# Update UI overlay (every 3 frames to reduce overhead)
	if metrics_overlay and Engine.get_process_frames() % 3 == 0:
		metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
		metrics_overlay.update_progress(timeline, 60.0)
	
	# Dynamic particle LOD based on performance (check every 10 frames)
	if particle_lod_enabled and particles.emitting and Engine.get_process_frames() % 10 == 0:
		optimize_particles_for_performance(fps)
	
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
		if metrics_overlay:
			metrics_overlay.update_phase(2, "HDR + Shadows")
	elif timeline >= 24.0 and not phase_triggered[2]:
		phase_triggered[2] = true
		phase = 3
		current_phase_key = "phase_3"
		transition_to_phase_3()
		if metrics_overlay:
			metrics_overlay.update_phase(3, "Materials + Reflections")
	elif timeline >= 36.0 and not phase_triggered[3]:
		phase_triggered[3] = true
		phase = 4
		current_phase_key = "phase_4"
		transition_to_phase_4()
		if metrics_overlay:
			metrics_overlay.update_phase(4, "Particles + Glow")
	elif timeline >= 48.0 and not phase_triggered[4]:
		phase_triggered[4] = true
		phase = 5
		current_phase_key = "phase_5"
		transition_to_phase_5()
		if metrics_overlay:
			metrics_overlay.update_phase(5, "Maximum Complexity")
	elif timeline >= 60.0 and not phase_triggered[5]:
		phase_triggered[5] = true
		finish_showcase()

func optimize_particles_for_performance(current_fps: float):
	"""Dynamic LOD system for particles based on real-time FPS"""
	if not particles.emitting:
		return
	
	var target_particles = max_safe_particles.get(current_quality_preset, 500)
	
	# Dynamic LOD: reduce particles if FPS drops
	if current_fps < 20.0:
		# Severe performance issues - drastically reduce
		particles.amount = int(target_particles * 0.5)
		if particles.amount != int(target_particles * 0.5):  # Only print on change
			print("  [LOD] Heavily reduced particles to %d (FPS: %.1f)" % [particles.amount, current_fps])
	elif current_fps < 25.0:
		# Moderate performance issues - reduce by 30%
		particles.amount = int(target_particles * 0.7)
		if particles.amount != int(target_particles * 0.7):
			print("  [LOD] Reduced particles to %d (FPS: %.1f)" % [particles.amount, current_fps])
	else:
		# Performance is acceptable - use target count
		particles.amount = target_particles

func aggregate_second_data():
	"""Aggregate per-frame data into per-second metrics"""
	if current_second_data["fps"].size() == 0:
		return
	
	var avg_fps = 0.0
	var avg_ft = 0.0
	var avg_cpu = 0.0
	var avg_temp = 0.0
	var avg_gpu = 0.0
	
	for i in current_second_data["fps"].size():
		avg_fps += current_second_data["fps"][i]
		avg_ft += current_second_data["frame_times"][i]
		avg_cpu += current_second_data["cpu"][i]
		avg_temp += current_second_data["temps"][i]
		avg_gpu += current_second_data["gpu"][i]
	
	avg_fps /= current_second_data["fps"].size()
	avg_ft /= current_second_data["frame_times"].size()
	avg_cpu /= current_second_data["cpu"].size()
	avg_temp /= current_second_data["temps"].size()
	avg_gpu /= current_second_data["gpu"].size()
	
	per_second_metrics.push_back({
		"second": int(timeline),
		"phase": phase,
		"fps": avg_fps,
		"frame_time": avg_ft,
		"cpu": avg_cpu,
		"temp": avg_temp,
		"gpu": avg_gpu
	})
	
	# Clear for next second (reuse arrays instead of recreating)
	for key in current_second_data.keys():
		current_second_data[key].clear()

func calculate_percentiles(data: Array) -> Dictionary:
	"""Calculate percentile statistics for a data array"""
	if data.size() == 0:
		return {"p1": 0.0, "p5": 0.0, "p50": 0.0, "p95": 0.0, "p99": 0.0}
	
	# Sort in-place to avoid allocation (data is not reused after export)
	data.sort()
	
	return {
		"p1": data[int(data.size() * 0.01)],
		"p5": data[int(data.size() * 0.05)],
		"p50": data[int(data.size() * 0.50)],  # Median
		"p95": data[int(data.size() * 0.95)],
		"p99": data[int(data.size() * 0.99)]
	}

func calculate_average(data: Array) -> float:
	"""Calculate average of array values"""
	if data.size() == 0:
		return 0.0
	var sum = 0.0
	for val in data:
		sum += val
	return sum / data.size()

func calculate_stability_score(fps_data: Array) -> float:
	"""Calculate stability score based on FPS variance (0-100, higher is better)"""
	if fps_data.size() < 2:
		return 100.0
	
	var avg = calculate_average(fps_data)
	var variance = 0.0
	for fps in fps_data:
		variance += pow(fps - avg, 2)
	variance /= fps_data.size()
	var std_dev = sqrt(variance)
	
	# Convert to 0-100 score (lower std_dev = better)
	return max(0.0, 100.0 - (std_dev * 2))

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
	
	# Yield to allow GC opportunity during transition
	await get_tree().process_frame
	
	# Enable shadows
	light.shadow_enabled = true
	light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	
	# Load HDR environment (pre-loaded in _ready, should be cached)
	var hdr_path = "res://art/model-test/sunflowers_puresky_2k.hdr"
	if ResourceLoader.exists(hdr_path):
		var sky = Sky.new()
		var sky_material = PanoramaSkyMaterial.new()
		sky_material.panorama = load(hdr_path)  # Should be instant (cached)
		sky.sky_material = sky_material
		env.environment.background_mode = Environment.BG_SKY
		env.environment.sky = sky
		print("  ✓ HDR environment loaded (from cache)")
	else:
		print("  ⚠ HDR not found, using color background")

func transition_to_phase_3():
	print("\n[Phase 3] Enhanced Materials + Reflections (24-36s)")
	
	# Yield to allow GC opportunity during transition
	await get_tree().process_frame
	
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
	
	# Yield to allow GC opportunity during transition
	await get_tree().process_frame
	
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
		
		# Enable particles with optimized count for stability
		var particle_count = max_safe_particles.get(current_quality_preset, 1000)
		particles.amount = particle_count
		particles.emitting = true
		
		print("  ✓ Particles (%d) and glow enabled" % particles.amount)
	else:
		print("  - Skipped (Low/Potato quality)")

func start_fadeout():
	print("\n[Phase 5.5] Fade to Black (55-60s)")
	print("  - Syncing with audio fade-out")

func transition_to_phase_5():
	print("\n[Phase 5] Maximum Complexity (48-60s)")
	
	# Yield to allow GC opportunity during transition
	await get_tree().process_frame
	
	# Only enable for High+ quality
	if current_quality_preset >= 3:  # High or higher
		print("  - Maximum effects and particle count")
		
		# Increase glow intensity (push to maximum!)
		if env.environment.glow_enabled:
			env.environment.glow_intensity = 1.0  # Maximum
			env.environment.glow_bloom = 0.2  # Increased
		
		# Increase particle count based on quality (optimized for stability)
		if particles.emitting:
			var particle_count = max_safe_particles.get(current_quality_preset, 2000)
			particles.amount = particle_count
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
	"""Export comprehensive benchmark results with percentiles and per-second data"""
	var results = {
		"benchmark": "Model Showcase",
		"version": "1.1",
		"duration": 60.0,
		"timestamp": Time.get_datetime_string_from_system(),
		"platform": {},
		"phases": {},
		"per_second": per_second_metrics,
		"summary": {}
	}
	
	# Add platform info if available
	if platform_detector:
		results["platform"] = {
			"name": platform_detector.get_platform_name(),
			"cpu": platform_detector.get_cpu_model(),
			"ram_mb": platform_detector.get_ram_mb(),
			"gpu": platform_detector.get_gpu_vendor()
		}
	
	# Process each phase with comprehensive metrics
	# Pre-allocate all_fps array to prevent resizing
	var total_samples = 0
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5"]:
		total_samples += metrics[phase_key]["fps"].size()
	
	var all_fps = []
	all_fps.resize(total_samples)
	all_fps.clear()
	
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5"]:
		var fps_data = metrics[phase_key]["fps"]
		var frame_time_data = metrics[phase_key]["frame_times"]
		var cpu_data = metrics[phase_key]["cpu"]
		var temp_data = metrics[phase_key]["temps"]
		var gpu_data = metrics[phase_key]["gpu"]
		
		if fps_data.size() > 0:
			all_fps.append_array(fps_data)
			
			# Calculate percentiles
			var fps_percentiles = calculate_percentiles(fps_data)
			var ft_percentiles = calculate_percentiles(frame_time_data)
			
			# Find min/max values
			var min_fps = fps_data[0]
			var max_fps = fps_data[0]
			var max_temp = temp_data[0] if temp_data.size() > 0 else 0
			var max_gpu = gpu_data[0] if gpu_data.size() > 0 else 0
			
			for i in fps_data.size():
				min_fps = min(min_fps, fps_data[i])
				max_fps = max(max_fps, fps_data[i])
				if i < temp_data.size():
					max_temp = max(max_temp, temp_data[i])
				if i < gpu_data.size():
					max_gpu = max(max_gpu, gpu_data[i])
			
			results["phases"][phase_key] = {
				"avg_fps": calculate_average(fps_data),
				"min_fps": min_fps,
				"max_fps": max_fps,
				"fps_percentiles": fps_percentiles,
				"avg_frame_time_ms": calculate_average(frame_time_data),
				"frame_time_percentiles": ft_percentiles,
				"avg_temperature": calculate_average(temp_data),
				"max_temperature": max_temp,
				"avg_gpu_usage": calculate_average(gpu_data),
				"max_gpu_usage": max_gpu,
				"sample_count": fps_data.size()
			}
	
	# Overall summary with stability score
	results["summary"] = {
		"overall_avg_fps": calculate_average(all_fps),
		"overall_percentiles": calculate_percentiles(all_fps),
		"stability_score": calculate_stability_score(all_fps)
	}
	
	# Save with timestamp in filename
	var timestamp_str = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://model_showcase_%s.json" % timestamp_str
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(results, "\t"))
		file.close()
		print("\n✓ Results exported to: %s" % filename)
		print("  (Location: %s)" % OS.get_user_data_dir())
		print("\n  Overall Performance:")
		print("    Avg FPS: %.1f" % results["summary"]["overall_avg_fps"])
		print("    1%% Low: %.1f" % results["summary"]["overall_percentiles"]["p1"])
		print("    Stability: %.1f/100" % results["summary"]["stability_score"])
	else:
		print("\n✗ Failed to export results")

func _input(event):
	# Allow ESC to exit early
	if event.is_action_pressed("ui_cancel"):
		print("\n[ModelShowcase] Cancelled by user")
		get_tree().change_scene_to_file("res://scenes/main.tscn")


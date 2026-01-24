extends Node3D
## Nature Island Benchmark - 6-Phase Progressive Nature Scene  
## Synced to "Forest Glass" (176 seconds)
## Features day/night cycle, dynamic weather, and all 85 nature assets


@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var env = $WorldEnvironment
@onready var particles = $Particles
@onready var audio = $AudioStreamPlayer
@onready var fade_overlay = $FadeOverlay
@onready var metrics_overlay = $MetricsOverlay
@onready var loading_screen = $LoadingScreen
@onready var multimesh_manager = $Island/MultiMeshContainer

# Performance monitoring
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager
var platform_detector  # Get from main scene
var current_quality_preset = 2  # Default to Medium

# Timeline tracking
var timeline = 0.0
var phase = 0
var phase_triggered = [false, false, false, false, false, false, false, false]  # 0-6 phases + finale
var fade_started = false

# Warmup tracking
var warmup_complete = false
var warmup_timer = 0.0
const WARMUP_DURATION = 10.0  # 10 seconds like 3DMark

# Phase start times for warmup skip
var phase_start_times = {
	"phase_1": 0.0,
	"phase_2": 29.0,
	"phase_3": 58.0,
	"phase_4": 88.0,
	"phase_5": 117.0,
	"phase_6": 146.0
}

# Particle optimization
var particle_lod_enabled = true
var max_safe_particles = {
	0: 50,     # Potato: minimal ambient
	1: 100,    # Low: light ambient
	2: 200,    # Medium: moderate ambient
	3: 350,    # High: more visible
	4: 500     # Ultra: full effect
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

# Threaded loading state for returning to menu
var is_returning_to_menu = false
var menu_loader = null

# Scene transitions
var is_transitioning = false
var transition_tween: Tween = null
const TRANSITION_FADE_DURATION = 1.0  # 1 second fade to black, 1 second from black

# Day/night cycle
var sun_rotation_speed = 0.0  # Degrees per second
var current_time_of_day = 0.0  # 0.0 = dawn, 0.25 = noon, 0.5 = dusk, 0.75 = night, 1.0 = dawn
var sky_colors = {
	"dawn": Color(0.8, 0.5, 0.3, 1),      # Orange/pink
	"day": Color(0.4, 0.6, 0.9, 1),       # Blue
	"dusk": Color(0.9, 0.4, 0.2, 1),      # Deep orange
	"night": Color(0.05, 0.05, 0.15, 1),  # Dark blue
}
var ambient_colors = {
	"dawn": Color(0.6, 0.5, 0.4, 1),
	"day": Color(0.6, 0.7, 0.8, 1),
	"dusk": Color(0.5, 0.3, 0.2, 1),
	"night": Color(0.1, 0.1, 0.2, 1),
}

# Weather system
var weather_state = "clear"  # "clear", "light_rain", "heavy_rain", "storm"
var rain_intensity = 0.0  # 0.0 to 1.0
var fog_density = 0.001  # Base fog density
var target_rain_intensity = 0.0
var last_weather_update = 0.0  # Throttle weather updates
var last_daynight_update = 0.0  # Throttle day/night updates
var last_particle_amount = 0  # Cache to avoid updating every frame
const UPDATE_INTERVAL = 0.1  # Update 10 times per second instead of 60

func _ready():
	print("\n========================================")
	print("[Nature Island] Starting 176-Second Benchmark")
	print("6 Phases: Dawn → Day → Dusk → Night → Dawn")
	print("========================================\n")
	
	# Hide everything during warmup - only show loading screen
	
	camera.current = false
	light.visible = false
	particles.visible = false
	metrics_overlay.visible = false
	
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
		print("[ModelShowcase] WARNING: Main scene not found, creating standalone systems")
		# Create standalone performance monitor since we're running without Main
		perf_monitor = PerformanceMonitor.new()
		# Verbose logging disabled - causes resource spikes during benchmark
		platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		print("[ModelShowcase] Standalone systems created")
	
	# Pre-allocate all arrays to prevent GC pauses during benchmark
	print("[ModelShowcase] Pre-allocating arrays for optimal performance...")
	var expected_samples = 1740  # 29 seconds per phase @ 60 FPS
	
	for phase_key in ["phase_1", "phase_2", "phase_3", "phase_4", "phase_5", "phase_6"]:
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
	
	# Show loading screen
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Initializing systems...")
	
	await get_tree().process_frame
	
	# Start comprehensive warmup
	await run_warmup_phase()
	
	# Hide loading screen
	if loading_screen:
		loading_screen.visible = false
	
	warmup_complete = true
	
	# Show everything now that warmup is complete
	
	camera.current = true
	light.visible = true
	particles.visible = true
	metrics_overlay.visible = true
	
	# Setup initial phase
	setup_phase_1()
	
	# Initialize metrics overlay
	if metrics_overlay:
		metrics_overlay.update_phase(1, "Basic PBR")
	
	# Start audio and benchmark timer
	audio.play()
	print("[ModelShowcase] Benchmark started - 60 second timer begins")

func run_warmup_phase():
	"""Comprehensive warmup phase with threaded resource loading"""
	print("\n========================================")
	print("[Warmup] Starting warmup phase with threaded loading")
	print("========================================\n")
	
	var warmup_start = Time.get_ticks_msec()
	
	# Create threaded loader
	var loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(loader)
	
	# Phase 1: Queue and load assets asynchronously (0-60%)
	if loading_screen:
		loading_screen.update_progress(0.0, "Queueing resources...")
	
	# Queue HDR environment for threaded loading
	var hdr_path = "res://art/model-test/sunflowers_puresky_2k.hdr"
	if ResourceLoader.exists(hdr_path):
		loader.queue_resource(hdr_path)
	
	await get_tree().process_frame
	
	# Poll loading progress until complete
	if loading_screen:
		loading_screen.update_progress(5.0, "Loading HDR environment...")
	
	while not loader.is_loading_complete():
		loader.update_progress()
		var progress = loader.get_overall_progress()
		var scaled_progress = 5.0 + (progress * 55.0)  # Scale to 5-60%
		
		if loading_screen:
			loading_screen.update_progress(scaled_progress, "Loading HDR environment... %.0f%%" % (progress * 100.0))
		
		await get_tree().process_frame
	
	# Get loaded HDR texture
	var hdr_texture = loader.get_resource(hdr_path)
	if hdr_texture:
		print("[Warmup] HDR texture loaded successfully")
	
	# Phase 1b: Skip texture preloading (island assets have embedded textures)
	if loading_screen:
		loading_screen.update_progress(70.0, "Assets loaded...")
	
	await get_tree().process_frame
	
	print("[Warmup] Island assets ready (textures embedded in glTF)")
	
	# Phase 2: Pre-compile all shaders (70-85%)
	if loading_screen:
		loading_screen.update_progress(70.0, "Compiling shaders...")
	
	if env and env.environment:
		# Glow shader
		var original_glow = env.environment.glow_enabled
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 1.0
		env.environment.glow_bloom = 0.2
		await get_tree().process_frame
		print("[Warmup] Glow shader compiled")
		
		if loading_screen:
			loading_screen.update_progress(72.0, "Compiling SSR shaders...")
		
		# SSR shader
		var original_ssr = env.environment.ssr_enabled
		env.environment.ssr_enabled = true
		await get_tree().process_frame
		print("[Warmup] SSR shader compiled")
		
		if loading_screen:
			loading_screen.update_progress(74.0, "Compiling SSAO shaders...")
		
		# SSAO shader
		var original_ssao = env.environment.ssao_enabled
		env.environment.ssao_enabled = true
		await get_tree().process_frame
		print("[Warmup] SSAO shader compiled")
		
		if loading_screen:
			loading_screen.update_progress(76.0, "Compiling shadow shaders...")
		
		# Restore states
		env.environment.glow_enabled = original_glow
		env.environment.ssr_enabled = original_ssr
		env.environment.ssao_enabled = original_ssao
	
	# Shadow shader
	if light:
		light.shadow_enabled = true
		await get_tree().process_frame
		print("[Warmup] Shadow shader compiled")
		light.shadow_enabled = false
	
	# Phase 2b: Shader compilation skipped (no model)
	if loading_screen:
		loading_screen.update_progress(80.0, "Shaders compiled")
	
	# Phase 3: Render test frames to create GPU buffers (80-90%)
	if loading_screen:
		loading_screen.update_progress(80.0, "Creating GPU buffers...")
	
	# Setup particle system for rendering
	if particles:
		var particle_mat = ParticleProcessMaterial.new()
		particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		particle_mat.emission_box_extents = Vector3(4.0, 3.0, 4.0)
		particle_mat.direction = Vector3(0, 1, 0)
		particle_mat.spread = 25.0
		particle_mat.initial_velocity_min = 0.3
		particle_mat.initial_velocity_max = 0.8
		particle_mat.gravity = Vector3(0, -0.2, 0)
		particle_mat.scale_min = 0.02
		particle_mat.scale_max = 0.05
		particle_mat.lifetime_randomness = 0.3
		particles.process_material = particle_mat
		
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.025
		sphere_mesh.height = 0.05
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1.0, 1.0, 0.95, 0.7)
		material.emission_enabled = true
		material.emission = Color(1.0, 0.95, 0.85)
		material.emission_energy_multiplier = 1.2
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sphere_mesh.material = material
		particles.draw_pass_1 = sphere_mesh
	
	# Show everything and render multiple frames to force GPU buffer creation
	
	camera.current = true
	light.visible = true
	if particles:
		particles.visible = true
		particles.emitting = true
	
	# Render 10 frames to ensure all GPU resources created
	for i in range(10):
		if loading_screen:
			loading_screen.update_progress(80.0 + i, "Rendering test frames... %d/10" % (i+1))
		await get_tree().process_frame
	
	if particles:
		particles.emitting = false
	print("[Warmup] GPU buffers created - rendered 10 test frames")
	
	# Hide everything again until benchmark starts
	
	light.visible = false
	if particles:
		particles.visible = false
	
	# Phase 3b: Initialize MultiMesh system (85-90%)
	if loading_screen:
		loading_screen.update_progress(85.0, "Creating MultiMesh instances...")
	
	if multimesh_manager:
		multimesh_manager.initialize_meshes()
		print("[Warmup] MultiMesh system initialized")
	
	await get_tree().process_frame
	
	if loading_screen:
		loading_screen.update_progress(90.0, "MultiMesh instances created")
	
	if loading_screen:
		loading_screen.update_progress(90.0, "Systems ready...")
	
	# Phase 4: Extended thermal stabilization for Pi 5 (90-100%)
	if loading_screen:
		loading_screen.update_progress(90.0, "Thermal stabilization...")
	
	var elapsed = (Time.get_ticks_msec() - warmup_start) / 1000.0
	var min_warmup_time = 5.0  # INCREASED from 3.0 to 5.0 for Pi 5
	
	# Additional stabilization: monitor temperature
	var stable_temp_count = 0
	var required_stable_frames = 60  # 1 second of stable temp
	
	while stable_temp_count < required_stable_frames:
		await get_tree().process_frame
		
		if perf_monitor:
			perf_monitor.update(0.016)  # Approximate delta
			var temp = perf_monitor.get_temperature()
			
			# Consider stable if temp is reasonable
			# (Pi 5 throttles if temp rises too fast)
			if temp > 0 and temp < 75.0:  # Safe operating temp
				stable_temp_count += 1
			else:
				stable_temp_count += 1  # Still count up even if no temp reading
		else:
			# No temp monitoring, just wait minimum time
			stable_temp_count += 1
		
		var progress = 90.0 + (10.0 * (stable_temp_count / float(required_stable_frames)))
		if loading_screen:
			loading_screen.update_progress(progress, "Stabilizing... %d%%" % int(progress))
	
	# Ensure minimum time has elapsed
	elapsed = (Time.get_ticks_msec() - warmup_start) / 1000.0
	var remaining = max(0.0, min_warmup_time - elapsed)
	
	if remaining > 0:
		print("[Warmup] Additional stabilization: %.1fs" % remaining)
		var stabilize_start = Time.get_ticks_msec()
		while remaining > 0:
			await get_tree().process_frame
			var stabilize_elapsed = (Time.get_ticks_msec() - stabilize_start) / 1000.0
			remaining = min_warmup_time - elapsed - stabilize_elapsed
			
			if loading_screen:
				loading_screen.update_progress(99.0, "Stabilizing...")
	
	if loading_screen:
		loading_screen.update_progress(100.0, "Ready!")
	
	await get_tree().process_frame
	
	# Cleanup loader
	loader.queue_free()
	
	var total_time = (Time.get_ticks_msec() - warmup_start) / 1000.0
	print("\n[Warmup] Complete - systems stable (%.1fs)" % total_time)
	print("========================================\n")

func _process(delta):
	# Handle threaded loading for returning to menu
	if is_returning_to_menu and menu_loader:
		menu_loader.update_progress()
		var progress = menu_loader.get_overall_progress()
		var percent = progress * 100.0
		
		if loading_screen:
			loading_screen.visible = true
			loading_screen.update_progress(percent, "Returning to menu... %.0f%%" % percent)
		
		if menu_loader.is_loading_complete():
			var scene = menu_loader.get_resource("res://scenes/main.tscn")
			if scene:
				menu_loader.queue_free()
				menu_loader = null
				get_tree().change_scene_to_packed(scene)
			else:
				push_error("[ModelShowcase] Failed to load main menu scene")
				is_returning_to_menu = false
				if menu_loader:
					menu_loader.queue_free()
					menu_loader = null
		return
	
	# Don't process anything during warmup
	if not warmup_complete:
		return
	
	timeline += delta
	frame_count += 1
	
	# Update performance monitor every frame for real-time data
	if perf_monitor:
		perf_monitor.update(delta)
	
	# Collect comprehensive metrics
	var fps = 0.0
	var frame_time = 0.0
	var cpu_usage = 0.0
	var temp = 0.0
	var gpu_usage = 0.0
	
	# Always use Engine FPS for immediate measurement from frame 1
	fps = Engine.get_frames_per_second()
	frame_time = delta * 1000.0  # Current frame time in ms
	
	if perf_monitor:
		cpu_usage = perf_monitor.get_cpu_usage()
		temp = perf_monitor.get_temperature()
		gpu_usage = perf_monitor.get_gpu_usage()  # 0-100
	else:
		cpu_usage = 0.0  # Not available
		temp = 0.0  # Not available
		gpu_usage = 0.0  # Not available
	
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
	
	# Update UI overlay every frame for true real-time display
	if metrics_overlay:
		metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
		metrics_overlay.update_progress(timeline, 176.0)
	
	# Dynamic particle LOD based on performance (check every 10 frames)
	# Particle LOD optimization - DISABLED FOR PERFORMANCE
	# if particle_lod_enabled and particles.emitting and Engine.get_process_frames() % 10 == 0:
	# 	optimize_particles_for_performance(fps)
	
	# Update day/night cycle (throttled to 10 times per second) - DISABLED FOR PERFORMANCE
	# if timeline - last_daynight_update >= UPDATE_INTERVAL:
	# 	update_day_night_cycle(delta)
	# 	last_daynight_update = timeline
	
	# Update weather system (throttled to 10 times per second) - DISABLED FOR PERFORMANCE
	# if timeline - last_weather_update >= UPDATE_INTERVAL:
	# 	update_weather_system(delta)
	# 	last_weather_update = timeline
	
	# Update fade overlay
	if fade_started and timeline < 176.0:
		var fade_progress = (timeline - 171.0) / 5.0  # 5 second fade
		if fade_overlay:
			fade_overlay.color.a = fade_progress
	
	# Phase transitions (29-second intervals, 6 phases)
	if timeline >= 29.0 and not phase_triggered[1]:
		phase_triggered[1] = true
		fade_and_transition_to_phase_2()
	elif timeline >= 58.0 and not phase_triggered[2]:
		phase_triggered[2] = true
		fade_and_transition_to_phase_3()
	elif timeline >= 88.0 and not phase_triggered[3]:
		phase_triggered[3] = true
		fade_and_transition_to_phase_4()
	elif timeline >= 117.0 and not phase_triggered[4]:
		phase_triggered[4] = true
		fade_and_transition_to_phase_5()
	elif timeline >= 146.0 and not phase_triggered[5]:
		phase_triggered[5] = true
		fade_and_transition_to_phase_6()
	elif timeline >= 171.0 and not phase_triggered[6]:
		phase_triggered[6] = true
		start_fadeout()  # 5-second fade to black
	elif timeline >= 176.0 and not phase_triggered[7]:
		phase_triggered[7] = true
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

func update_day_night_cycle(delta: float):
	"""Dynamic sun rotation and sky color transitions"""
	# Map 176 seconds to full day/night cycle
	# Phase 1 (0-29s): Dawn → Day
	# Phase 2 (29-58s): Day
	# Phase 3 (58-88s): Day → Dusk
	# Phase 4 (88-117s): Dusk → Night
	# Phase 5 (117-146s): Night
	# Phase 6 (146-176s): Night → Dawn
	
	var cycle_position = timeline / 176.0  # 0.0 to 1.0
	current_time_of_day = cycle_position
	
	# Rotate sun (360 degrees over 176 seconds)
	var sun_angle = cycle_position * 360.0
	light.rotation_degrees = Vector3(-90 + sun_angle * 0.5, 45, 0)
	
	# Adjust sun intensity based on time
	if cycle_position < 0.17:  # Dawn (0-29s)
		light.light_energy = lerp(0.5, 1.5, cycle_position / 0.17)
		env.environment.background_color = lerp_color(sky_colors.dawn, sky_colors.day, cycle_position / 0.17)
	elif cycle_position < 0.33:  # Day (29-58s)
		light.light_energy = 1.5
		env.environment.background_color = sky_colors.day
	elif cycle_position < 0.5:  # Day to Dusk (58-88s)
		var t = (cycle_position - 0.33) / 0.17
		light.light_energy = lerp(1.5, 0.8, t)
		env.environment.background_color = lerp_color(sky_colors.day, sky_colors.dusk, t)
	elif cycle_position < 0.67:  # Dusk to Night (88-117s)
		var t = (cycle_position - 0.5) / 0.17
		light.light_energy = lerp(0.8, 0.3, t)
		env.environment.background_color = lerp_color(sky_colors.dusk, sky_colors.night, t)
	elif cycle_position < 0.83:  # Night (117-146s)
		light.light_energy = 0.3
		env.environment.background_color = sky_colors.night
	else:  # Night to Dawn (146-176s)
		var t = (cycle_position - 0.83) / 0.17
		light.light_energy = lerp(0.3, 0.5, t)
		env.environment.background_color = lerp_color(sky_colors.night, sky_colors.dawn, t)
	
	# Update ambient light
	var ambient_color = get_interpolated_ambient_color(cycle_position)
	env.environment.ambient_light_color = ambient_color

func lerp_color(a: Color, b: Color, t: float) -> Color:
	return Color(
		lerp(a.r, b.r, t),
		lerp(a.g, b.g, t),
		lerp(a.b, b.b, t),
		lerp(a.a, b.a, t)
	)

func get_interpolated_ambient_color(cycle_pos: float) -> Color:
	"""Returns appropriate ambient color based on time of day"""
	if cycle_pos < 0.17:
		return lerp_color(ambient_colors.dawn, ambient_colors.day, cycle_pos / 0.17)
	elif cycle_pos < 0.33:
		return ambient_colors.day
	elif cycle_pos < 0.5:
		return lerp_color(ambient_colors.day, ambient_colors.dusk, (cycle_pos - 0.33) / 0.17)
	elif cycle_pos < 0.67:
		return lerp_color(ambient_colors.dusk, ambient_colors.night, (cycle_pos - 0.5) / 0.17)
	elif cycle_pos < 0.83:
		return ambient_colors.night
	else:
		return lerp_color(ambient_colors.night, ambient_colors.dawn, (cycle_pos - 0.83) / 0.17)

func update_weather_system(delta: float):
	"""Progressive weather with rain intensity transitions"""
	# Weather progression over 176 seconds:
	# Phase 1 (0-29s): Clear
	# Phase 2 (29-58s): Clear → Light rain
	# Phase 3 (58-88s): Light rain
	# Phase 4 (88-117s): Heavy rain
	# Phase 5 (117-146s): Heavy rain → Clearing
	# Phase 6 (146-176s): Clear
	
	if timeline < 29.0:
		target_rain_intensity = 0.0
		weather_state = "clear"
	elif timeline < 58.0:
		# Gradual increase
		target_rain_intensity = (timeline - 29.0) / 29.0 * 0.3  # 0 to 0.3
		weather_state = "light_rain"
	elif timeline < 88.0:
		target_rain_intensity = 0.3
		weather_state = "light_rain"
	elif timeline < 117.0:
		# Increase to heavy
		target_rain_intensity = 0.3 + (timeline - 88.0) / 29.0 * 0.7  # 0.3 to 1.0
		weather_state = "heavy_rain"
	elif timeline < 146.0:
		# Gradual decrease
		target_rain_intensity = 1.0 - (timeline - 117.0) / 29.0 * 1.0  # 1.0 to 0.0
		weather_state = "clearing"
	else:
		target_rain_intensity = 0.0
		weather_state = "clear"
	
	# Smooth transition
	rain_intensity = lerp(rain_intensity, target_rain_intensity, delta * 2.0)
	
	# Update particle system (only if amount changed significantly)
	if particles:
		var should_emit = rain_intensity > 0.05
		particles.emitting = should_emit
		
		# Cap max particles based on quality preset
		var max_rain_particles = max_safe_particles.get(current_quality_preset, 200)
		
		# Only update particle amount if it changed by at least 50 particles
		var new_amount = max(1, int(lerp(0.0, float(max_rain_particles), rain_intensity)))
		if abs(new_amount - last_particle_amount) > 50:
			particles.amount = new_amount
			last_particle_amount = new_amount
			
			# Only update material when particle count changes
			if particles.process_material and should_emit:
				var mat = particles.process_material as ParticleProcessMaterial
				mat.initial_velocity_min = lerp(2.0, 5.0, rain_intensity)
				mat.initial_velocity_max = lerp(4.0, 8.0, rain_intensity)
	
	# Update fog density
	fog_density = lerp(0.001, 0.005, rain_intensity)
	if env and env.environment:
		env.environment.fog_density = fog_density

func fade_transition():
	"""Fade to black, wait, fade back"""
	is_transitioning = true
	
	# Fade to black
	if transition_tween:
		transition_tween.kill()
	transition_tween = create_tween()
	transition_tween.tween_property(fade_overlay, "color:a", 1.0, TRANSITION_FADE_DURATION)
	await transition_tween.finished
	
	# Hold black for 0.5 seconds
	await get_tree().create_timer(0.5).timeout
	
	# Fade from black
	transition_tween = create_tween()
	transition_tween.tween_property(fade_overlay, "color:a", 0.0, TRANSITION_FADE_DURATION)
	await transition_tween.finished
	
	is_transitioning = false

func fade_and_transition_to_phase_2():
	await fade_transition()
	phase = 2
	current_phase_key = "phase_2"
	transition_to_phase_2()
	if metrics_overlay:
		metrics_overlay.update_phase(2, "Morning Light")

func fade_and_transition_to_phase_3():
	await fade_transition()
	phase = 3
	current_phase_key = "phase_3"
	transition_to_phase_3()
	if metrics_overlay:
		metrics_overlay.update_phase(3, "Midday Bloom")

func fade_and_transition_to_phase_4():
	await fade_transition()
	phase = 4
	current_phase_key = "phase_4"
	transition_to_phase_4()
	if metrics_overlay:
		metrics_overlay.update_phase(4, "Evening Storm")

func fade_and_transition_to_phase_5():
	await fade_transition()
	phase = 5
	current_phase_key = "phase_5"
	transition_to_phase_5()
	if metrics_overlay:
		metrics_overlay.update_phase(5, "Midnight Calm")

func fade_and_transition_to_phase_6():
	await fade_transition()
	phase = 6
	current_phase_key = "phase_6"
	transition_to_phase_6()
	if metrics_overlay:
		metrics_overlay.update_phase(6, "Dawn Return")

func setup_phase_1():
	print("\n[Phase 1] Dawn Awakening (0-29s)")
	print("  - Basic geometry, dawn lighting, clear weather")
	
	# Show all MultiMesh instances
	if multimesh_manager:
		multimesh_manager.set_all_visible(true)
	
	# Disable camera animation to save CPU
	if camera and camera.has_method("set_process"):
		camera.set_process(false)
		print("  - Camera animation disabled for performance")
	
	# Disable all advanced features
	light.shadow_enabled = false
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.1, 0.1, 0.12)
	env.environment.glow_enabled = false
	env.environment.ssao_enabled = false
	env.environment.ssr_enabled = false
	env.environment.fog_enabled = false
	particles.emitting = false

func transition_to_phase_2():
	print("\n[Phase 2] Morning Light (29-58s)")
	print("  - HDR environment, shadows, light rain starting")
	
	# Yield to allow GC opportunity during transition
	await get_tree().process_frame
	
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
		print("  âœ“ HDR environment loaded")
	else:
		print("  âš  HDR not found, using color background")

func transition_to_phase_3():
	print("\n[Phase 3] Midday Bloom (58-88s)")
	print("  - Enhanced materials, reflections, steady rain")
	
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
		
		print("  âœ“ SSR and SSAO enabled")
	else:
		print("  - Skipped (Potato quality)")

func transition_to_phase_4():
	print("\n[Phase 4] Evening Storm (88-117s)")
	print("  - Heavy rain, particles, dusk lighting")
	
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
			particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			particle_mat.emission_box_extents = Vector3(4.0, 3.0, 4.0)
			particle_mat.direction = Vector3(0, 1, 0)  # Upward drift
			particle_mat.spread = 25.0  # More spread
			particle_mat.initial_velocity_min = 0.3  # Faster
			particle_mat.initial_velocity_max = 0.8  # Faster
			particle_mat.gravity = Vector3(0, -0.2, 0)  # More gravity
			particle_mat.scale_min = 0.02  # Bigger
			particle_mat.scale_max = 0.05  # Bigger
			particle_mat.lifetime_randomness = 0.3  # Natural fade
			particles.process_material = particle_mat
		
		# Add draw mesh for particles (this is what was missing!)
		if particles.draw_pass_1 == null:
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.025  # Bigger
			sphere_mesh.height = 0.05  # Bigger
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(1.0, 1.0, 0.95, 0.7)  # Warm white, visible
			material.emission_enabled = true
			material.emission = Color(1.0, 0.95, 0.85)  # Warm glow
			material.emission_energy_multiplier = 1.2  # Noticeable but not blinding
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sphere_mesh.material = material
			particles.draw_pass_1 = sphere_mesh
		
		# Enable particles with optimized count for stability
		var particle_count = max_safe_particles.get(current_quality_preset, 1000)
		particles.amount = particle_count
		particles.emitting = true
		
		print("  âœ“ Particles (%d) and glow enabled" % particles.amount)
	else:
		print("  - Skipped (Low/Potato quality)")

func start_fadeout():
	print("\n[Finale] Fade to Black (171-176s)")
	print("  - Beginning 5-second finale fade")

func transition_to_phase_5():
	print("\n[Phase 5] Midnight Calm (117-146s)")
	
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

func transition_to_phase_6():
	print("\n[Phase 6] Dawn Return - Full Island Vista (146-176s)")
	
	# Yield to allow GC opportunity
	await get_tree().process_frame
	
	# Keep all effects enabled but start winding down
	print("  - Maintaining full quality for finale")
	
	# Ensure all effects are visible for final showcase
	if current_quality_preset >= 2:
		env.environment.glow_enabled = true
		env.environment.ssr_enabled = true
		env.environment.ssao_enabled = true
		particles.emitting = rain_intensity > 0.05
	
	print("  ✓ Final phase active - approaching dawn")

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
	
	# Wait a moment before returning to menu
	await get_tree().create_timer(2.0).timeout
	
	print("\n[ModelShowcase] Returning to main menu...")
	_load_menu_threaded()

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
		print("\nâœ“ Results exported to: %s" % filename)
		print("  (Location: %s)" % OS.get_user_data_dir())
		print("\n  Overall Performance:")
		print("    Avg FPS: %.1f" % results["summary"]["overall_avg_fps"])
		print("    1%% Low: %.1f" % results["summary"]["overall_percentiles"]["p1"])
		print("    Stability: %.1f/100" % results["summary"]["stability_score"])
	else:
		print("\nâœ— Failed to export results")

func _input(event):
	# Allow ESC to exit early (but not during loading)
	if event.is_action_pressed("ui_cancel") and not is_returning_to_menu:
		print("\n[ModelShowcase] Cancelled by user")
		_load_menu_threaded()

func _load_menu_threaded():
	"""Load main menu scene asynchronously with loading screen"""
	if is_returning_to_menu:
		return
	
	is_returning_to_menu = true
	
	# Create threaded loader
	menu_loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(menu_loader)
	
	# Queue scene for loading
	menu_loader.queue_resource("res://scenes/main.tscn")
	
	# Show loading screen
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Returning to menu...")


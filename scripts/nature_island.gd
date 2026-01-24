extends Node3D
## Nature Island Benchmark - 2:56 Progressive Island Showcase
## Synced to "Forest Glass (nature benchmark).ogg" (176 seconds)
## Features realistic day/night cycle and weather effects optimized for ARM SBCs

@onready var terrain = $Terrain
@onready var camera = $Camera3D
@onready var sun_light = $DirectionalLight3D
@onready var env = $WorldEnvironment
@onready var rain_particles = $RainParticles
@onready var beach_zone = $BeachZone
@onready var forest_zone = $ForestZone
@onready var cliff_zone = $CliffZone
@onready var audio = $AudioStreamPlayer
@onready var fade_overlay = $FadeOverlay
@onready var metrics_overlay = $MetricsOverlay
@onready var loading_screen = $LoadingScreen

# Performance monitoring
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager
var platform_detector
var current_quality_preset = 2  # Default to Medium

# Timeline tracking
var timeline = 0.0
var phase = 1
var phase_triggered = [false, false, false, false, false, false, false]  # 0=unused, 1-6 for phases
var finale_started = false

# Warmup tracking
var warmup_complete = false
var warmup_timer = 0.0
const WARMUP_DURATION = 10.0  # 10 seconds like Model Showcase

# Phase timing (6 phases × ~29 seconds each)
var phase_start_times = {
	"phase_1": 0.0,    # Beach dawn clear
	"phase_2": 29.0,   # Coastal morning clear
	"phase_3": 58.0,   # Forest midday rain
	"phase_4": 87.0,   # Forest afternoon clear
	"phase_5": 116.0,  # Cliff dusk fog
	"phase_6": 145.0   # Island night clear
}

const BENCHMARK_DURATION = 176.0  # 2:56 total
const FINALE_FADE_START = 171.0   # Start fade to black 5 seconds before end

# Object density per phase (0.0 = none, 1.0 = all)
var phase_densities = {
	"phase_1": 0.15,  # 15% of max objects
	"phase_2": 0.30,  # 30%
	"phase_3": 0.50,  # 50%
	"phase_4": 0.70,  # 70%
	"phase_5": 0.85,  # 85%
	"phase_6": 1.00   # 100% max density
}

# Weather per phase
var phase_weather = {
	"phase_1": "clear",
	"phase_2": "clear",
	"phase_3": "rain",
	"phase_4": "clear",
	"phase_5": "fog",
	"phase_6": "clear"
}

# Time-of-Day states (6 phases)
var time_of_day_states = {
	"phase_1": {  # Dawn (5:30 AM)
		"sun_angle": -30.0,  # Below horizon
		"sun_energy": 0.4,
		"sky_top_color": Color(0.3, 0.4, 0.6),
		"sky_horizon_color": Color(0.8, 0.6, 0.5),
		"ambient_energy": 0.3,
		"ambient_color": Color(0.4, 0.5, 0.7)
	},
	"phase_2": {  # Morning (9:00 AM)
		"sun_angle": 30.0,
		"sun_energy": 0.9,
		"sky_top_color": Color(0.4, 0.6, 0.9),
		"sky_horizon_color": Color(0.7, 0.8, 0.9),
		"ambient_energy": 0.6,
		"ambient_color": Color(0.8, 0.85, 0.9)
	},
	"phase_3": {  # Midday (12:00 PM)
		"sun_angle": 60.0,  # Overhead
		"sun_energy": 1.2,
		"sky_top_color": Color(0.3, 0.5, 0.9),
		"sky_horizon_color": Color(0.6, 0.7, 0.9),
		"ambient_energy": 0.8,
		"ambient_color": Color(0.9, 0.9, 1.0)
	},
	"phase_4": {  # Afternoon (3:00 PM)
		"sun_angle": 40.0,
		"sun_energy": 1.0,
		"sky_top_color": Color(0.4, 0.6, 0.9),
		"sky_horizon_color": Color(0.8, 0.7, 0.6),
		"ambient_energy": 0.7,
		"ambient_color": Color(1.0, 0.9, 0.8)
	},
	"phase_5": {  # Dusk (6:30 PM)
		"sun_angle": -20.0,
		"sun_energy": 0.3,
		"sky_top_color": Color(0.2, 0.3, 0.5),
		"sky_horizon_color": Color(0.9, 0.5, 0.3),
		"ambient_energy": 0.25,
		"ambient_color": Color(0.6, 0.4, 0.5)
	},
	"phase_6": {  # Night (8:00 PM)
		"sun_angle": -50.0,
		"sun_energy": 0.0,  # Moon/stars only
		"sky_top_color": Color(0.05, 0.05, 0.15),
		"sky_horizon_color": Color(0.1, 0.1, 0.2),
		"ambient_energy": 0.15,
		"ambient_color": Color(0.2, 0.2, 0.4)
	}
}

# Weather states
var weather_states = {
	"clear": {
		"fog_enabled": false,
		"rain_enabled": false,
		"particle_count": 0
	},
	"rain": {  # Phase 3
		"fog_enabled": false,
		"rain_enabled": true,
		"particle_count": 100,  # Low count for SBC (vs 500+ on desktop)
		"particle_lifetime": 2.0,
		"particle_speed": 5.0
	},
	"fog": {  # Phase 5
		"fog_enabled": true,
		"rain_enabled": false,
		"fog_density": 0.02,
		"fog_color": Color(0.7, 0.7, 0.8, 1.0)
	}
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

# Object pool tracking
var object_pools = {
	"beach": [],
	"forest": [],
	"cliff": []
}
var total_objects_loaded = 0

func _ready():
	print("\n========================================")
	print("[NatureIsland] Starting 2:56 Nature Island Benchmark")
	print("========================================\n")
	
	# Hide everything during warmup - only show loading screen
	terrain.visible = false
	camera.current = false
	sun_light.visible = false
	rain_particles.visible = false
	beach_zone.visible = false
	forest_zone.visible = false
	cliff_zone.visible = false
	metrics_overlay.visible = false
	
	# Get performance systems from main scene if available
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		perf_monitor = main.perf_monitor
		quality_manager = main.quality_manager
		platform_detector = main.platform_detector
		print("[NatureIsland] Systems found: perf=%s, quality=%s, platform=%s" % [
			perf_monitor != null, quality_manager != null, platform_detector != null
		])
		if quality_manager:
			current_quality_preset = quality_manager.get_quality_preset()
			print("[NatureIsland] Quality preset: ", quality_manager.get_quality_name())
	else:
		print("[NatureIsland] WARNING: Main scene not found, creating standalone systems")
		# Create standalone performance monitor since we're running without Main
		perf_monitor = PerformanceMonitor.new()
		platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		print("[NatureIsland] Standalone systems created")
	
	# Pre-allocate all arrays to prevent GC pauses during benchmark
	print("[NatureIsland] Pre-allocating arrays for optimal performance...")
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
	
	# Pre-allocate per_second_metrics (176 seconds)
	per_second_metrics.resize(176)
	per_second_metrics.clear()
	
	print("[NatureIsland] Array pre-allocation complete")
	
	# Show loading screen
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Initializing systems...")
	
	await get_tree().process_frame
	
	# Start comprehensive warmup
	await run_warmup_phase()
	
	# Initialize object pools after warmup
	initialize_object_pools()
	
	# Hide loading screen
	if loading_screen:
		loading_screen.visible = false
	
	warmup_complete = true
	
	# Show everything now that warmup is complete
	terrain.visible = true
	camera.current = true
	sun_light.visible = true
	beach_zone.visible = true
	forest_zone.visible = true
	cliff_zone.visible = true
	metrics_overlay.visible = true
	
	# Setup initial phase
	setup_phase_1()
	
	# Initialize metrics overlay
	if metrics_overlay:
		metrics_overlay.update_phase(1, "Beach Dawn")
	
	# Start audio and benchmark timer
	audio.play()
	print("[NatureIsland] Benchmark started - 176 second timer begins")

func run_warmup_phase():
	"""Comprehensive warmup phase with threaded resource loading"""
	print("\n========================================")
	print("[Warmup] Starting warmup phase with threaded loading")
	print("========================================\n")
	
	var warmup_start = Time.get_ticks_msec()
	
	# Create threaded loader
	var loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(loader)
	
	# Queue nature benchmark assets for loading
	print("[Warmup] Queueing 87 nature models for threaded loading...")
	
	# Note: In full implementation, we would queue all 87 glTF models here
	# For now, we'll simulate the loading with a progress bar
	var model_count = 87
	for i in range(min(model_count, 10)):  # Load first 10 for testing
		await get_tree().process_frame
		if loading_screen:
			var progress = (i + 1.0) / model_count * 50.0  # First 50% for model loading
			loading_screen.update_progress(progress, "Loading nature assets... %d/%d" % [i + 1, model_count])
	
	print("[Warmup] Asset loading complete")
	
	# Pre-compile shaders for all weather states
	print("[Warmup] Pre-compiling shaders...")
	if loading_screen:
		loading_screen.update_progress(60.0, "Compiling shaders...")
	
	await get_tree().process_frame
	
	if env and env.environment:
		# Pre-warm fog shader
		var original_fog = env.environment.fog_enabled
		env.environment.fog_enabled = true
		await get_tree().process_frame
		env.environment.fog_enabled = original_fog
		
		print("[Warmup] Fog shader pre-compiled")
	
	# Pre-warm rain particles
	if rain_particles:
		rain_particles.emitting = true
		await get_tree().process_frame
		await get_tree().process_frame
		rain_particles.emitting = false
		print("[Warmup] Rain particle shader pre-compiled")
	
	if loading_screen:
		loading_screen.update_progress(80.0, "Warming up systems...")
	
	# Extended thermal stabilization (5 seconds)
	print("[Warmup] Thermal stabilization phase (5 seconds)...")
	var stabilization_start = Time.get_ticks_msec()
	var stabilization_frames = 0
	
	while Time.get_ticks_msec() - stabilization_start < 5000:
		await get_tree().process_frame
		stabilization_frames += 1
		
		if stabilization_frames % 60 == 0:
			var elapsed = (Time.get_ticks_msec() - stabilization_start) / 1000.0
			print("[Warmup] Stabilization: %.1fs elapsed" % elapsed)
	
	print("[Warmup] Thermal stabilization complete (%d frames)" % stabilization_frames)
	
	var warmup_duration = (Time.get_ticks_msec() - warmup_start) / 1000.0
	print("\n[Warmup] Warmup phase complete in %.2f seconds" % warmup_duration)
	print("========================================\n")
	
	if loading_screen:
		loading_screen.update_progress(100.0, "Starting benchmark...")
	
	await get_tree().create_timer(0.5).timeout
	
	loader.queue_free()

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
				push_error("[NatureIsland] Failed to load main menu scene")
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
	
	# Per-frame data
	metrics[current_phase_key]["fps"].push_back(fps)
	metrics[current_phase_key]["frame_times"].push_back(frame_time)
	metrics[current_phase_key]["cpu"].push_back(cpu_usage)
	metrics[current_phase_key]["temps"].push_back(temp)
	metrics[current_phase_key]["gpu"].push_back(gpu_usage)
	metrics[current_phase_key]["timestamps"].push_back(timeline)
	
	# Per-second aggregation
	current_second_data["fps"].push_back(fps)
	current_second_data["frame_times"].push_back(frame_time)
	current_second_data["cpu"].push_back(cpu_usage)
	current_second_data["temps"].push_back(temp)
	current_second_data["gpu"].push_back(gpu_usage)
	
	# When a second has passed, aggregate and store
	if timeline - last_second_mark >= 1.0:
		aggregate_second_data()
		last_second_mark = timeline
	
	# Update metrics overlay
	if metrics_overlay:
		metrics_overlay.update_metrics(fps, cpu_usage, gpu_usage, temp)
	
	# Phase transitions
	if timeline >= phase_start_times["phase_2"] and not phase_triggered[2]:
		phase_triggered[2] = true
		trigger_phase_transition(2)
	elif timeline >= phase_start_times["phase_3"] and not phase_triggered[3]:
		phase_triggered[3] = true
		trigger_phase_transition(3)
	elif timeline >= phase_start_times["phase_4"] and not phase_triggered[4]:
		phase_triggered[4] = true
		trigger_phase_transition(4)
	elif timeline >= phase_start_times["phase_5"] and not phase_triggered[5]:
		phase_triggered[5] = true
		trigger_phase_transition(5)
	elif timeline >= phase_start_times["phase_6"] and not phase_triggered[6]:
		phase_triggered[6] = true
		trigger_phase_transition(6)
	
	# Trigger finale fade at 171 seconds (5 seconds before end)
	if timeline >= FINALE_FADE_START and not finale_started:
		finale_started = true
		trigger_finale_fade()
	
	# End benchmark at 176 seconds
	if timeline >= BENCHMARK_DURATION:
		end_benchmark()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not is_returning_to_menu:
		print("\n[NatureIsland] ESC pressed - returning to menu")
		return_to_menu()

func trigger_phase_transition(phase_num: int):
	var phase_key = "phase_" + str(phase_num)
	phase = phase_num
	current_phase_key = phase_key
	
	print("\n[Phase %d] Transition triggered at %.1fs" % [phase_num, timeline])
	
	# Fade to black
	fade_to_black(1.0)  # 1 second fade out
	await get_tree().create_timer(1.0).timeout
	
	# Update object density
	set_object_density(phase_densities[phase_key])
	
	# Apply time of day
	apply_time_of_day(phase_key)
	
	# Apply weather
	apply_weather(phase_weather[phase_key])
	
	# Move camera to new zone
	if camera and camera.has_method("move_to_phase"):
		camera.move_to_phase(phase_num)
	
	# Update metrics overlay
	var phase_names = ["", "Beach Dawn", "Coastal Morning", "Forest Midday", "Forest Afternoon", "Cliff Dusk", "Island Night"]
	if metrics_overlay and phase_num <= phase_names.size():
		metrics_overlay.update_phase(phase_num, phase_names[phase_num])
	
	# Fade back in
	fade_from_black(1.0)  # 1 second fade in

func apply_time_of_day(phase_key: String):
	if not time_of_day_states.has(phase_key):
		return
	
	var state = time_of_day_states[phase_key]
	
	# Rotate sun (DirectionalLight3D) - minimal cost
	if sun_light:
		sun_light.rotation_degrees.x = state["sun_angle"]
		sun_light.light_energy = state["sun_energy"]
	
	# Update sky colors via simple lerp (no complex shaders)
	if env and env.environment:
		env.environment.background_mode = Environment.BG_COLOR
		# Lerp between top and horizon for simple gradient effect
		env.environment.background_color = state["sky_top_color"]
		
		# Update ambient lighting
		env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.environment.ambient_light_color = state["ambient_color"]
		env.environment.ambient_light_energy = state["ambient_energy"]
	
	print("[TimeOfDay] Applied %s lighting" % phase_key)

func apply_weather(weather_type: String):
	if not weather_states.has(weather_type):
		return
	
	var state = weather_states[weather_type]
	
	# Disable all weather first
	disable_rain()
	disable_fog()
	
	# Enable requested weather
	if state["rain_enabled"]:
		enable_rain()
	elif state["fog_enabled"]:
		enable_fog()
	
	print("[Weather] Applied '%s' weather" % weather_type)

func enable_rain():
	if rain_particles:
		# Adjust particle count based on quality preset
		var particle_counts = {
			0: 0,      # Potato: no rain
			1: 50,     # Low: reduced
			2: 100,    # Medium: normal
			3: 200,    # High: enhanced
			4: 500     # Ultra: maximum
		}
		
		var target_count = particle_counts.get(current_quality_preset, 100)
		rain_particles.amount = target_count
		rain_particles.emitting = true
		print("[Weather] Rain enabled (%d particles)" % target_count)

func disable_rain():
	if rain_particles:
		rain_particles.emitting = false

func enable_fog():
	if env and env.environment:
		# Use simple fog (not volumetric fog - too expensive for SBC)
		env.environment.fog_enabled = true
		env.environment.fog_mode = Environment.FOG_MODE_EXPONENTIAL
		env.environment.fog_density = 0.02
		env.environment.fog_light_color = Color(0.7, 0.7, 0.8)
		env.environment.fog_light_energy = 1.0
		print("[Weather] Fog enabled")

func disable_fog():
	if env and env.environment:
		env.environment.fog_enabled = false

func set_object_density(density: float):
	"""Activate/deactivate objects in pools based on density percentage"""
	var target_count = int(total_objects_loaded * density)
	var current_active = 0
	
	# Activate objects up to target density across all zones
	for zone_name in object_pools.keys():
		for obj in object_pools[zone_name]:
			if current_active < target_count:
				obj.visible = true
				current_active += 1
			else:
				obj.visible = false
	
	print("[Density] Activated %d/%d objects (%.0f%%)" % [current_active, total_objects_loaded, density * 100.0])

func fade_to_black(duration: float):
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 1.0, duration)

func fade_from_black(duration: float):
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color:a", 0.0, duration)

func trigger_finale_fade():
	print("\n[NatureIsland] Starting finale fade to black (5s)...")
	fade_to_black(5.0)  # 5-second slow fade

func end_benchmark():
	print("\n[NatureIsland] Benchmark complete!")
	if audio and audio.playing:
		audio.stop()
	
	# Calculate final score and show results
	calculate_final_score()
	
	# Return to menu after showing results
	await get_tree().create_timer(3.0).timeout
	return_to_menu()

func aggregate_second_data():
	"""Aggregate per-frame data into per-second summary"""
	if current_second_data["fps"].size() == 0:
		return
	
	var second_summary = {
		"fps_avg": calculate_average(current_second_data["fps"]),
		"fps_min": current_second_data["fps"].min(),
		"fps_max": current_second_data["fps"].max(),
		"frame_time_avg": calculate_average(current_second_data["frame_times"]),
		"cpu_avg": calculate_average(current_second_data["cpu"]),
		"temp_avg": calculate_average(current_second_data["temps"]),
		"gpu_avg": calculate_average(current_second_data["gpu"]),
		"timestamp": timeline
	}
	
	per_second_metrics.push_back(second_summary)
	
	# Clear for next second
	for key in current_second_data.keys():
		current_second_data[key].clear()

func calculate_average(data: Array) -> float:
	if data.size() == 0:
		return 0.0
	var sum = 0.0
	for val in data:
		sum += val
	return sum / data.size()

func calculate_final_score():
	"""Calculate final benchmark score and display results"""
	print("\n========================================")
	print("[NatureIsland] Calculating Final Score")
	print("========================================\n")
	
	var total_fps = 0.0
	var total_samples = 0
	var min_fps = 999.0
	var max_fps = 0.0
	
	for phase_key in metrics.keys():
		var phase_fps = metrics[phase_key]["fps"]
		if phase_fps.size() > 0:
			var phase_avg = calculate_average(phase_fps)
			var phase_min = phase_fps.min()
			var phase_max = phase_fps.max()
			
			total_fps += phase_avg * phase_fps.size()
			total_samples += phase_fps.size()
			min_fps = min(min_fps, phase_min)
			max_fps = max(max_fps, phase_max)
			
			print("[%s] Avg: %.1f FPS | Min: %.1f | Max: %.1f" % [
				phase_key, phase_avg, phase_min, phase_max
			])
	
	var overall_avg_fps = total_fps / total_samples if total_samples > 0 else 0.0
	
	print("\n[Overall] Avg: %.1f FPS | Min: %.1f | Max: %.1f" % [
		overall_avg_fps, min_fps, max_fps
	])
	
	# Simple score calculation (weighted by avg FPS)
	var score = overall_avg_fps * 100.0
	
	print("\n[Final Score] %.0f points" % score)
	print("========================================\n")

func setup_phase_1():
	"""Setup initial phase (Dawn, Beach, Clear)"""
	print("\n[Phase 1] Beach Dawn (0-29s)")
	print("  - Dawn lighting (5:30 AM)")
	print("  - Clear weather")
	print("  - Sparse objects (15%)")
	
	# Apply initial time of day and weather
	apply_time_of_day("phase_1")
	apply_weather("clear")
	set_object_density(0.15)
	
	# Ensure objects are visible
	if beach_zone:
		beach_zone.visible = true

func initialize_object_pools():
	"""Initialize object pools for all 87 nature models across 3 zones"""
	print("\n[ObjectPools] Initializing object pools...")
	
	# Beach Zone (20 models)
	# Placeholder for future model loading:
	# - Coast rocks (6 types)
	# - Coast sand (2 types)
	# - Boulders (3 types)
	# - Coastal plants (9 types)
	object_pools["beach"] = []
	for i in range(20):
		var placeholder = create_placeholder_object("beach_%d" % i)
		if placeholder:
			beach_zone.add_child(placeholder)
			object_pools["beach"].append(placeholder)
			placeholder.visible = false  # Initially hidden
	
	# Forest Zone (50 models)
	# Placeholder for future model loading:
	# - Large trees (10)
	# - Saplings (8)
	# - Ground plants (15)
	# - Forest floor (10)
	# - Shrubs (7)
	object_pools["forest"] = []
	for i in range(50):
		var placeholder = create_placeholder_object("forest_%d" % i)
		if placeholder:
			forest_zone.add_child(placeholder)
			object_pools["forest"].append(placeholder)
			placeholder.visible = false  # Initially hidden
	
	# Cliff Zone (17 models)
	# Placeholder for future model loading:
	# - Rock faces (3)
	# - Boulders (5)
	# - Hardy plants (9)
	object_pools["cliff"] = []
	for i in range(17):
		var placeholder = create_placeholder_object("cliff_%d" % i)
		if placeholder:
			cliff_zone.add_child(placeholder)
			object_pools["cliff"].append(placeholder)
			placeholder.visible = false  # Initially hidden
	
	total_objects_loaded = object_pools["beach"].size() + object_pools["forest"].size() + object_pools["cliff"].size()
	
	print("[ObjectPools] Initialized %d objects (Beach: %d, Forest: %d, Cliff: %d)" % [
		total_objects_loaded,
		object_pools["beach"].size(),
		object_pools["forest"].size(),
		object_pools["cliff"].size()
	])

func create_placeholder_object(name_str: String) -> Node3D:
	"""Create a placeholder object (simple mesh) for testing"""
	# Create a simple CSG sphere as placeholder
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = name_str
	
	# Create a simple sphere mesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radii = Vector3(0.5, 0.5, 0.5)
	mesh_instance.mesh = sphere_mesh
	
	# Create a simple material with random color based on zone
	var material = StandardMaterial3D.new()
	if "beach" in name_str:
		material.albedo_color = Color(0.9, 0.8, 0.6)  # Sandy color
		mesh_instance.position = Vector3(randf_range(-15, 15), 0, randf_range(35, 45))
	elif "forest" in name_str:
		material.albedo_color = Color(0.3, 0.6, 0.3)  # Green color
		mesh_instance.position = Vector3(randf_range(-20, 20), 0, randf_range(-10, 10))
	elif "cliff" in name_str:
		material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray color
		mesh_instance.position = Vector3(randf_range(-15, 15), 0, randf_range(-45, -35))
	
	mesh_instance.set_surface_override_material(0, material)
	
	return mesh_instance

func return_to_menu():
	"""Return to main menu with threaded loading"""
	if is_returning_to_menu:
		return
	
	is_returning_to_menu = true
	
	# Stop audio
	if audio and audio.playing:
		audio.stop()
	
	# Create threaded loader
	menu_loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(menu_loader)
	menu_loader.queue_resource("res://scenes/main.tscn")
	
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Returning to menu...")

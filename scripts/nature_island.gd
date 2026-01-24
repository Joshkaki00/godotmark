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
		metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
		metrics_overlay.update_progress(timeline, BENCHMARK_DURATION)
	
	# Phase transitions
	if timeline >= phase_start_times["phase_2"] and not phase_triggered[2]:
		phase_triggered[2] = true
		call_deferred("trigger_phase_transition", 2)
	elif timeline >= phase_start_times["phase_3"] and not phase_triggered[3]:
		phase_triggered[3] = true
		call_deferred("trigger_phase_transition", 3)
	elif timeline >= phase_start_times["phase_4"] and not phase_triggered[4]:
		phase_triggered[4] = true
		call_deferred("trigger_phase_transition", 4)
	elif timeline >= phase_start_times["phase_5"] and not phase_triggered[5]:
		phase_triggered[5] = true
		call_deferred("trigger_phase_transition", 5)
	elif timeline >= phase_start_times["phase_6"] and not phase_triggered[6]:
		phase_triggered[6] = true
		call_deferred("trigger_phase_transition", 6)
	
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
	
	# Start fade-to-black transition (non-blocking, 3 seconds)
	fade_to_black(3.0)
	
	# Wait until fade is halfway before applying changes
	await get_tree().create_timer(1.5).timeout
	
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
	
	# Fade back in (non-blocking, 3 seconds)
	fade_from_black(3.0)

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
	print("\n[ObjectPools] Initializing object pools with real nature assets...")
	
	# Beach Zone Models (20 coastal models)
	var beach_models = [
		# Coast rocks and formations
		"coast_rocks_02_2k.gltf",
		"coast_rocks_03_2k.gltf",
		"coast_land_rocks_04_2k.gltf",
		"coast_line_02_2k.gltf",
		"boulder_01_2k.gltf",
		"stone_01_2k.gltf",
		# Coast sand and ground
		"coast_sand_01_2k.gltf",
		"coast_sand_02_2k.gltf",
		"coast_sand_rocks_02_2k.gltf",
		# Coastal plants
		"grass_bermuda_01_2k.gltf",
		"crystalline_iceplant_2k.gltf",
		"cheiridopsis_succulent_2k.gltf",
		"othonna_cerarioides_2k.gltf",
		"sand_rocks_small_01_2k.gltf",
		# Small coastal vegetation
		"shrub_01_2k.gltf",
		"shrub_02_2k.gltf",
		"flower_empodium_2k.gltf",
		"flower_gazania_2k.gltf",
		"flower_heliophila_2k.gltf",
		"weed_plant_02_2k.gltf"
	]
	
	# Forest Zone Models (50 forest models)
	var forest_models = [
		# Large trees (canopy)
		"fir_tree_01_2k.gltf",
		"island_tree_01_2k.gltf",
		"island_tree_02_2k.gltf",
		"island_tree_03_2k.gltf",
		"jacaranda_tree_2k.gltf",
		"tree_small_02_2k.gltf",
		# Saplings (mid-layer)
		"fir_sapling_2k.gltf",
		"fir_sapling_medium_2k.gltf",
		"pine_sapling_small_2k.gltf",
		# Ground plants
		"fern_02_2k.gltf",
		"anthurium_botany_01_2k.gltf",
		"calathea_orbifolia_01_2k.gltf",
		"celandine_01_2k.gltf",
		"dandelion_01_2k.gltf",
		"nettle_plant_2k.gltf",
		"periwinkle_plant_2k.gltf",
		"pachira_aquatica_01_2k.gltf",
		# Grass varieties
		"grass_medium_01_2k.gltf",
		"grass_medium_02_2k.gltf",
		# Flowers
		"flower_stinkkruid_2k.gltf",
		"flower_ursinia_2k.gltf",
		# Forest floor coverage
		"forest_floor_2k.gltf",
		"forest_ground_04_2k.gltf",
		"forest_leaves_02_2k.gltf",
		"forest_leaves_03_2k.gltf",
		"forrest_ground_01_2k.gltf",
		"forrest_ground_03_2k.gltf",
		"leaves_forest_ground_2k.gltf",
		"moss_01_2k.gltf",
		"park_dirt_2k.gltf",
		# Ground materials
		"brown_mud_2k.gltf",
		"brown_mud_02_2k.gltf",
		"brown_mud_03_2k.gltf",
		"brown_mud_dry_2k.gltf",
		"burned_ground_01_2k.gltf",
		"red_dirt_mud_01_2k.gltf",
		# Roots and debris
		"root_cluster_01_2k.gltf",
		"root_cluster_02_2k.gltf",
		"single_root_2k.gltf",
		"pine_roots_2k.gltf",
		"bark_debris_01_2k.gltf",
		"dry_branches_medium_01_2k.gltf",
		# Stumps
		"tree_stump_01_2k.gltf",
		"tree_stump_02_2k.gltf",
		# Shrubs
		"shrub_03_2k.gltf",
		"shrub_04_2k.gltf",
		"searsia_burchellii_2k.gltf",
		"searsia_lucida_2k.gltf",
		"wild_rooibos_bush_2k.gltf"
	]
	
	# Cliff Zone Models (17 rocky/hardy models)
	var cliff_models = [
		# Rock faces (vertical cliffs)
		"rock_face_01_2k.gltf",
		"rock_face_02_2k.gltf",
		"rock_face_03_2k.gltf",
		"namaqualand_cliff_02_2k.gltf",
		"mountainside_2k.gltf",
		"rocky_trail_2k.gltf",
		# Large boulders
		"namaqualand_boulder_02_2k.gltf",
		"namaqualand_boulder_03_2k.gltf",
		"moon_rock_01_2k.gltf",
		"rock_moss_set_01_2k.gltf",
		"rock_moss_set_02_2k.gltf",
		# Hardy plants (cliff vegetation)
		"quiver_tree_01_2k.gltf",
		"quiver_tree_02_2k.gltf",
		"dead_quiver_trunk_2k.gltf",
		"dead_tree_trunk_2k.gltf",
		"dead_tree_trunk_02_2k.gltf",
		# Additional cliff elements
		"dead_tree_trunk_02_2k.gltf"
	]
	
	# Load Beach Zone models - COMPACT ISLAND SCALE
	# Island is centered at origin, scaled to fit in camera view (similar to Model Showcase scale)
	object_pools["beach"] = []
	var beach_zone_size = Vector2(6, 4)  # 6m wide, 4m deep (scaled down 5x)
	var beach_z_start = 2.0  # Start at Z +2 to +6
	
	for i in range(beach_models.size()):
		var model_path = "res://art/nature-benchmark/" + beach_models[i]
		var instance = load_and_position_model(model_path, "beach", i, beach_models.size(), beach_zone_size, beach_z_start)
		if instance:
			beach_zone.add_child(instance)
			object_pools["beach"].append(instance)
			instance.visible = false
	
	# Load Forest Zone models - CENTER OF ISLAND
	object_pools["forest"] = []
	var forest_zone_size = Vector2(8, 8)  # 8m wide, 8m deep (scaled down 5x)
	var forest_z_start = -4.0  # Center: Z -4 to +4
	
	for i in range(forest_models.size()):
		var model_path = "res://art/nature-benchmark/" + forest_models[i]
		var instance = load_and_position_model(model_path, "forest", i, forest_models.size(), forest_zone_size, forest_z_start)
		if instance:
			forest_zone.add_child(instance)
			object_pools["forest"].append(instance)
			instance.visible = false
	
	# Load Cliff Zone models - BACK OF ISLAND
	object_pools["cliff"] = []
	var cliff_zone_size = Vector2(5, 3)  # 5m wide, 3m deep (scaled down 5x)
	var cliff_z_start = -6.0  # Start at Z -6 to -9
	
	for i in range(cliff_models.size()):
		var model_path = "res://art/nature-benchmark/" + cliff_models[i]
		var instance = load_and_position_model(model_path, "cliff", i, cliff_models.size(), cliff_zone_size, cliff_z_start)
		if instance:
			cliff_zone.add_child(instance)
			object_pools["cliff"].append(instance)
			instance.visible = false
	
	total_objects_loaded = object_pools["beach"].size() + object_pools["forest"].size() + object_pools["cliff"].size()
	
	print("[ObjectPools] Initialized %d real nature models (Beach: %d, Forest: %d, Cliff: %d)" % [
		total_objects_loaded,
		object_pools["beach"].size(),
		object_pools["forest"].size(),
		object_pools["cliff"].size()
	])

func load_and_position_model(model_path: String, zone: String, index: int, total: int, zone_size: Vector2, z_start: float) -> Node3D:
	"""Load a glTF model and position it within its zone (0.5 acre = ~2000 sq meters total)"""
	if not ResourceLoader.exists(model_path):
		push_warning("[ObjectPools] Model not found: %s" % model_path)
		return null
	
	var packed_scene = load(model_path) as PackedScene
	if not packed_scene:
		push_warning("[ObjectPools] Failed to load: %s" % model_path)
		return null
	
	var instance = packed_scene.instantiate() as Node3D
	if not instance:
		push_warning("[ObjectPools] Failed to instantiate: %s" % model_path)
		return null
	
	# Position models in a grid pattern within their zone
	var cols = ceil(sqrt(total))
	var row = int(index / cols)
	var col = index % int(cols)
	
	# Calculate position with some randomization for natural look
	var x_spacing = zone_size.x / cols
	var z_spacing = zone_size.y / ceil(total / cols)
	
	var x_pos = (col * x_spacing) - (zone_size.x / 2.0) + randf_range(-x_spacing * 0.3, x_spacing * 0.3)
	var z_pos = z_start + (row * z_spacing) + randf_range(-z_spacing * 0.3, z_spacing * 0.3)
	
	# Y position based on zone type - create height variation for island terrain
	var y_pos = 0.0
	if zone == "cliff":
		y_pos = randf_range(0.3, 0.8)  # Elevated on cliff (scaled down)
	elif zone == "forest":
		y_pos = randf_range(0.05, 0.2)  # Slight elevation
	else:  # beach
		y_pos = randf_range(-0.05, 0.05)  # At sea level with slight variation
	
	instance.position = Vector3(x_pos, y_pos, z_pos)
	
	# Random rotation for natural variety
	instance.rotation.y = randf_range(0, TAU)
	
	# Scale variation - REDUCE OVERALL SCALE to fit compact island
	# Base scale is reduced to 0.3x to fit in camera view
	var base_scale = 0.3
	var scale_factor = base_scale
	
	if "tree" in model_path.to_lower() or "trunk" in model_path.to_lower():
		scale_factor = base_scale * randf_range(0.8, 1.2)  # Trees vary more
	elif "rock" in model_path.to_lower() or "boulder" in model_path.to_lower():
		scale_factor = base_scale * randf_range(0.7, 1.3)  # Rocks vary significantly
	else:
		scale_factor = base_scale * randf_range(0.9, 1.1)  # Small plants less variation
	
	instance.scale = Vector3.ONE * scale_factor
	
	# Add physics collision
	add_collision_to_model(instance, zone)
	
	# Enhance PBR materials
	enhance_model_materials(instance, zone)
	
	# Apply wind shader to vegetation
	apply_wind_shader_to_vegetation(instance)
	
	return instance

func add_collision_to_model(node: Node3D, zone: String) -> void:
	"""Add StaticBody3D with auto-generated convex collision shapes"""
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_inst = child as MeshInstance3D
			if mesh_inst.mesh:
				# Create StaticBody3D
				var static_body = StaticBody3D.new()
				static_body.name = "CollisionBody"
				
				# Create collision shape from mesh (convex for performance)
				var collision_shape = CollisionShape3D.new()
				var shape = mesh_inst.mesh.create_convex_shape()
				collision_shape.shape = shape
				
				# Add to tree
				static_body.add_child(collision_shape)
				mesh_inst.add_child(static_body)
				
				# Set collision layers (layer 2 = environment)
				static_body.collision_layer = 2
				static_body.collision_mask = 0  # Don't detect anything (static scenery)
		
		# Recurse for nested meshes
		add_collision_to_model(child, zone)

func enhance_model_materials(node: Node3D, zone: String) -> void:
	"""Enhance PBR properties based on zone type"""
	if node is MeshInstance3D:
		var mesh_inst = node as MeshInstance3D
		if mesh_inst.mesh:
			for surface_idx in range(mesh_inst.mesh.get_surface_count()):
				var mat = mesh_inst.mesh.surface_get_material(surface_idx)
				if mat is StandardMaterial3D:
					var enhanced_mat = mat.duplicate() as StandardMaterial3D
					
					# Zone-specific PBR tweaks
					if zone == "beach":
						# Beach materials: more reflective, wet sand
						enhanced_mat.metallic = 0.1
						enhanced_mat.roughness = 0.6
						enhanced_mat.rim_enabled = true
						enhanced_mat.rim = 0.3
					elif zone == "forest":
						# Forest: organic, less reflective
						enhanced_mat.metallic = 0.0
						enhanced_mat.roughness = 0.8
						enhanced_mat.ao_enabled = true
						enhanced_mat.ao_light_affect = 0.5
					elif zone == "cliff":
						# Cliff: rocky, sharp, exposed
						enhanced_mat.metallic = 0.05
						enhanced_mat.roughness = 0.9
					
					# Universal enhancements
					enhanced_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
					
					mesh_inst.set_surface_override_material(surface_idx, enhanced_mat)
	
	# Recurse to children
	for child in node.get_children():
		enhance_model_materials(child, zone)

func apply_wind_shader_to_vegetation(node: Node3D) -> void:
	"""Apply wind shader to plants, grass, trees"""
	var model_name = node.name.to_lower()
	var is_vegetation = (
		"grass" in model_name or "plant" in model_name or 
		"tree" in model_name or "fern" in model_name or
		"shrub" in model_name or "flower" in model_name or
		"sapling" in model_name
	)
	
	if is_vegetation and node is MeshInstance3D:
		var mesh_inst = node as MeshInstance3D
		if mesh_inst.mesh:
			var wind_shader = load("res://shaders/wind_vegetation.gdshader")
			if wind_shader:
				var shader_mat = ShaderMaterial.new()
				shader_mat.shader = wind_shader
				
				# Copy existing textures from original material
				var original_mat = mesh_inst.get_surface_override_material(0)
				if not original_mat:
					original_mat = mesh_inst.mesh.surface_get_material(0)
				
				if original_mat is StandardMaterial3D:
					shader_mat.set_shader_parameter("albedo_texture", original_mat.albedo_texture)
					shader_mat.set_shader_parameter("normal_texture", original_mat.normal_texture)
					shader_mat.set_shader_parameter("roughness_texture", original_mat.roughness_texture)
				
				# Set wind parameters based on plant type
				if "grass" in model_name:
					shader_mat.set_shader_parameter("wind_strength", 0.5)
					shader_mat.set_shader_parameter("wind_speed", 2.0)
				elif "tree" in model_name:
					shader_mat.set_shader_parameter("wind_strength", 0.2)
					shader_mat.set_shader_parameter("wind_speed", 0.8)
				else:
					shader_mat.set_shader_parameter("wind_strength", 0.3)
					shader_mat.set_shader_parameter("wind_speed", 1.5)
				
				mesh_inst.set_surface_override_material(0, shader_mat)
	
	# Recurse to children
	for child in node.get_children():
		apply_wind_shader_to_vegetation(child)

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

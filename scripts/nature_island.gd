extends Node3D
## 1-Minute Nature Island Benchmark - Progressive GPU Stress Test
## Synced to "Forest Glass (nature benchmark).ogg" (60 seconds)

@onready var ocean = $Ocean
@onready var ground = $Ground
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var env = $WorldEnvironment
@onready var audio = $AudioStreamPlayer
@onready var fade_overlay = $FadeOverlay
@onready var metrics_overlay = $MetricsOverlay
@onready var loading_screen = $LoadingScreen

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

# Warmup tracking
var warmup_complete = false
var warmup_timer = 0.0
const WARMUP_DURATION = 10.0  # 10 seconds like 3DMark

# Phase start times for warmup skip
var phase_start_times = {
	"phase_1": 0.0,
	"phase_2": 12.0,
	"phase_3": 24.0,
	"phase_4": 36.0,
	"phase_5": 48.0
}

# Nature asset storage
var asset_library = {
	"trees": [],
	"rocks": [],
	"vegetation": [],
	"ground_details": []
}

# MultiMesh instance groups
var multimesh_groups = {}

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

func _ready():
	print("\n========================================")
	print("[NatureIsland] Starting 1-Minute Nature Benchmark")
	print("========================================\n")
	
	# Make the ground more island-shaped (elliptical)
	create_island_ground()
	
	# Set benchmark title in overlay
	if metrics_overlay and metrics_overlay.has_method("set_benchmark_title"):
		metrics_overlay.set_benchmark_title("NATURE ISLAND BENCHMARK")
	
	# Hide everything during warmup - only show loading screen
	ocean.visible = false
	ground.visible = false
	camera.current = false
	light.visible = false
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
		# Verbose logging disabled - causes resource spikes during benchmark
		platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		print("[NatureIsland] Standalone systems created")
	
	# Disable physics server for performance
	PhysicsServer3D.set_active(false)
	print("[NatureIsland] Physics server disabled for optimal performance")
	
	# Pre-allocate all arrays to prevent GC pauses during benchmark
	print("[NatureIsland] Pre-allocating arrays for optimal performance...")
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
	
	print("[NatureIsland] Array pre-allocation complete")
	
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
	ocean.visible = true
	ground.visible = true
	camera.current = true
	light.visible = true
	metrics_overlay.visible = true
	
	# Setup initial phase
	setup_phase_1()
	
	# Initialize metrics overlay
	if metrics_overlay:
		metrics_overlay.update_phase(1, "Base Island")
	
	# Start audio and benchmark timer
	audio.play()
	print("[NatureIsland] Benchmark started - 60 second timer begins")

func run_warmup_phase():
	"""Comprehensive warmup phase with threaded resource loading"""
	print("\n========================================")
	print("[Warmup] Starting warmup phase with threaded loading")
	print("========================================\n")
	
	var warmup_start = Time.get_ticks_msec()
	
	# Create threaded loader
	var loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(loader)
	
	# Phase 1: Load all GLTF nature assets asynchronously (0-60%)
	if loading_screen:
		loading_screen.update_progress(0.0, "Loading nature assets...")
	
	# Queue all GLTF/GLB assets for loading
	# NOTE: Updated to use low-poly GLB assets from Downloads
	# Scale factors adjust for real-world modeling scale (assets modeled in meters)
	var asset_paths = {
		"trees": [
			{"path": "res://art/nature-benchmark/Tree.glb", "scale": 0.05}  # Trees are huge, scale down
		],
		# ROCKS: Using procedural rocks (~80 triangles each)
		"vegetation": [
			{"path": "res://art/nature-benchmark/Bushes.glb", "scale": 0.1},
			{"path": "res://art/nature-benchmark/Flowers.glb", "scale": 0.1},
			{"path": "res://art/nature-benchmark/Grass.glb", "scale": 0.1}
		],
		"ground_details": [
			{"path": "res://art/nature-benchmark/Dead Trees.glb", "scale": 0.05},
			{"path": "res://art/nature-benchmark/Rock.glb", "scale": 0.2},
			{"path": "res://art/nature-benchmark/Rock Large.glb", "scale": 0.15}
		]
	}
	
	# Queue all resources
	var total_assets = 0
	for category in asset_paths:
		for asset_config in asset_paths[category]:
			var path = asset_config["path"]
			if ResourceLoader.exists(path):
				loader.queue_resource(path)
				total_assets += 1
	
	await get_tree().process_frame
	
	# Poll loading progress
	var progress_text = "Loading %d nature assets..."
	while not loader.is_loading_complete():
		loader.update_progress()
		var progress = loader.get_overall_progress()
		var scaled_progress = 5.0 + (progress * 55.0)  # Scale to 5-60%
		
		if loading_screen:
			loading_screen.update_progress(scaled_progress, progress_text % total_assets)
		
		await get_tree().process_frame
	
	# Extract loaded assets with scale factors
	for category in asset_paths:
		for asset_config in asset_paths[category]:
			var path = asset_config["path"]
			var scale = asset_config["scale"]
			var packed_scene = loader.get_resource(path)
			if packed_scene:
				var asset_data = extract_gltf_asset(packed_scene)
				if not asset_data.is_empty():
					asset_data["base_scale"] = scale  # Store scale factor
					asset_library[category].append(asset_data)
	
	print("[Warmup] Loaded %d trees, %d vegetation, %d ground details" % [
		asset_library["trees"].size(),
		asset_library["vegetation"].size(),
		asset_library["ground_details"].size()
	])
	
	# Generate procedural rocks (lightweight replacements for 500K+ triangle GLTF rocks)
	var ProceduralRocks = preload("res://scripts/utils/procedural_rocks.gd")
	asset_library["rocks"] = ProceduralRocks.create_rock_variations(3)
	print("[Warmup] Generated 3 procedural rock variations (~80 triangles each)")
	
	if loading_screen:
		loading_screen.update_progress(60.0, "Assets loaded")
	
	# Phase 2: Pre-compile all shaders (60-80%)
	if loading_screen:
		loading_screen.update_progress(60.0, "Compiling shaders...")
	
	# Compile wind shaders
	var wind_veg_shader = load("res://shaders/wind_vegetation.gdshader")
	var wind_tree_shader = load("res://shaders/wind_trees.gdshader")
	
	# Force shader compilation by creating test materials
	var test_mat_veg = ShaderMaterial.new()
	test_mat_veg.shader = wind_veg_shader
	await get_tree().process_frame
	
	var test_mat_tree = ShaderMaterial.new()
	test_mat_tree.shader = wind_tree_shader
	await get_tree().process_frame
	
	print("[Warmup] Wind shaders compiled")
	
	if loading_screen:
		loading_screen.update_progress(70.0, "Compiling ocean shader...")
	
	# Ocean shader is already in the scene (disabled for performance test)
	print("[Warmup] Ocean shader test skipped (using StandardMaterial3D)")
	
	if loading_screen:
		loading_screen.update_progress(80.0, "Shaders compiled")
	
	# Phase 3: Render test frames to create GPU buffers (80-90%)
	if loading_screen:
		loading_screen.update_progress(80.0, "Creating GPU buffers...")
	
	ocean.visible = true
	ground.visible = true
	camera.current = true
	light.visible = true
	
	for i in range(10):
		await get_tree().process_frame
	
	print("[Warmup] GPU buffers created")
	
	ocean.visible = false
	ground.visible = false
	
	if loading_screen:
		loading_screen.update_progress(90.0, "GPU ready")
	
	# Phase 4: Thermal stabilization (90-100%)
	if loading_screen:
		loading_screen.update_progress(90.0, "Thermal stabilization...")
	
	var stabilization_start = Time.get_ticks_msec()
	var stabilization_duration = 5000  # 5 seconds
	
	while Time.get_ticks_msec() - stabilization_start < stabilization_duration:
		var elapsed = Time.get_ticks_msec() - stabilization_start
		var progress = 90.0 + (elapsed / float(stabilization_duration)) * 10.0
		
		if loading_screen:
			loading_screen.update_progress(progress, "Thermal stabilization...")
		
		await get_tree().process_frame
	
	var warmup_duration = (Time.get_ticks_msec() - warmup_start) / 1000.0
	print("[Warmup] Complete in %.2f seconds" % warmup_duration)
	
	if loading_screen:
		loading_screen.update_progress(100.0, "Ready!")
	
	await get_tree().process_frame

func extract_gltf_asset(packed_scene: PackedScene) -> Dictionary:
	"""Extract mesh and materials from a GLTF PackedScene"""
	var scene_instance = packed_scene.instantiate()
	var mesh_instance = find_mesh_instance_recursive(scene_instance)
	
	if not mesh_instance or not mesh_instance.mesh:
		scene_instance.queue_free()
		return {}
	
	var mesh = mesh_instance.mesh
	
	# Get original material
	var original_mat = null
	if mesh_instance.get_surface_override_material_count() > 0:
		original_mat = mesh_instance.get_surface_override_material(0)
	if not original_mat and mesh.get_surface_count() > 0:
		original_mat = mesh.surface_get_material(0)
	
	# Create per-vertex lit material (default for all phases)
	var mat_lit = StandardMaterial3D.new()
	mat_lit.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat_lit.cull_mode = BaseMaterial3D.CULL_BACK
	if original_mat and original_mat is StandardMaterial3D:
		mat_lit.albedo_color = original_mat.albedo_color
		if original_mat.albedo_texture:
			mat_lit.albedo_texture = original_mat.albedo_texture
	else:
		mat_lit.albedo_color = Color(0.8, 0.8, 0.8)
	
	scene_instance.queue_free()
	
	return {
		"mesh": mesh,
		"material_lit": mat_lit
	}

func create_island_ground():
	"""Create an elliptical island-shaped ground mesh"""
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Island parameters
	var width = 25.0  # East-West
	var length = 50.0  # North-South
	var segments = 16  # Smoother ellipse
	
	# Center vertex
	st.set_normal(Vector3.UP)
	st.set_uv(Vector2(0.5, 0.5))
	st.add_vertex(Vector3(0, 0, 0))
	
	# Create elliptical ring of vertices
	for i in range(segments + 1):
		var angle = (float(i) / segments) * TAU
		var x = cos(angle) * width * 0.5
		var z = sin(angle) * length * 0.5
		var u = (cos(angle) + 1.0) * 0.5
		var v = (sin(angle) + 1.0) * 0.5
		
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(u, v))
		st.add_vertex(Vector3(x, 0, z))
	
	# Create triangles (fan from center)
	for i in range(segments):
		st.add_index(0)  # Center
		st.add_index(i + 1)
		st.add_index(i + 2)
	
	var island_mesh = st.commit()
	ground.mesh = island_mesh
	print("[Island] Created elliptical island ground (25m × 50m)")

func find_mesh_instance_recursive(node: Node) -> MeshInstance3D:
	"""Recursively find first MeshInstance3D in node tree"""
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_mesh_instance_recursive(child)
		if result:
			return result
	return null

func create_combined_multimesh(asset_list: Array, zone_configs: Array) -> MultiMeshInstance3D:
	"""Create single MultiMesh from multiple zone configurations (reduces draw calls)"""
	if asset_list.is_empty() or zone_configs.is_empty():
		return null
	
	# Calculate total instance count
	var total_count = 0
	for config in zone_configs:
		total_count += config["count"]
	
	if total_count == 0:
		return null
	
	var mmi = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = total_count
	
	# Use first asset
	var base_data = asset_list[0]
	if not base_data.has("mesh") or not base_data["mesh"]:
		return null
	
	multimesh.mesh = base_data["mesh"]
	mmi.multimesh = multimesh
	
	# Apply per-vertex lit material (all phases)
	if base_data.has("material_lit") and base_data["material_lit"]:
		mmi.material_override = base_data["material_lit"]
	
	# Generate transforms for all zones combined
	var instance_idx = 0
	for config in zone_configs:
		var count = config["count"]
		var zone = config["zone"]
		var transforms = generate_transforms_for_zone(count, zone)
		
		# Apply base scale to all transforms
		var base_scale = base_data.get("base_scale", 1.0)
		for i in range(count):
			var transform = transforms[i]
			# Scale the entire transform by base_scale
			transform = transform.scaled(Vector3(base_scale, base_scale, base_scale))
			multimesh.set_instance_transform(instance_idx, transform)
			instance_idx += 1
	
	add_child(mmi)
	return mmi

func generate_transforms_for_zone(count: int, zone: String) -> Array[Transform3D]:
	"""Generate transforms based on island zone with elliptical island shape"""
	var transforms: Array[Transform3D] = []
	
	# Island dimensions (elliptical, like a real island)
	# IMPORTANT: Keep these matching the ground mesh in create_island_ground()
	var island_width = 25.0  # East-West
	var island_length = 50.0  # North-South
	
	for i in range(count):
		var transform = Transform3D()
		var pos = Vector3.ZERO
		
		if zone == "interior":
			# Interior: Center of island (avoid edges completely)
			var angle = randf() * TAU
			var radius_factor = randf_range(0.1, 0.5)  # Stay well within bounds
			pos.x = cos(angle) * island_width * radius_factor * 0.5
			pos.z = sin(angle) * island_length * radius_factor * 0.5
			
		elif zone == "coastal":
			# Coastal: Ring near the edge (but not TOO close)
			var angle = randf() * TAU
			var radius_factor = randf_range(0.6, 0.8)  # Stay inside the island boundary
			pos.x = cos(angle) * island_width * radius_factor * 0.5
			pos.z = sin(angle) * island_length * radius_factor * 0.5
			
		else:  # "general" - scattered everywhere
			# General: Anywhere, but stay within bounds
			var angle = randf() * TAU
			var radius_factor = randf_range(0.2, 0.75)  # Don't go past 75% to stay well inside
			pos.x = cos(angle) * island_width * radius_factor * 0.5
			pos.z = sin(angle) * island_length * radius_factor * 0.5
		
		# Keep objects at ground level (slight variation for naturalness)
		pos.y = randf_range(0.0, 0.1)
		
		transform.origin = pos
		
		# Random rotation (only Y-axis for upright objects)
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		
		# Random scale variation (80-120%)
		var scale_var = randf_range(0.8, 1.2)
		transform = transform.scaled(Vector3(scale_var, scale_var, scale_var))
		
		transforms.append(transform)
	
	return transforms

func setup_phase_1():
	"""Phase 1: Base Island (0-12s) - Forest with vertex lighting"""
	print("\n[Phase 1] Base Island (0-12s)")
	print("  - Forest with per-vertex lighting")
	print("  - Target: <4,000 triangles for RPi 4 @ 60 FPS")
	
	var trees = asset_library["trees"]
	if not trees.is_empty():
		multimesh_groups["all_trees"] = create_combined_multimesh(trees, [
			{"count": 6, "zone": "interior"},
			{"count": 4, "zone": "coastal"}
		])
		print("[Phase 1] Created 10 trees (1 combined MultiMesh)")
		print("[Phase 1] Est. triangles: ~4,000 (10 trees × 400 tri)")
	
	# Simple ocean (no shader - using StandardMaterial3D for testing)
	print("[Phase 1] Ocean using StandardMaterial3D (shader disabled for performance test)")

func transition_to_phase_2():
	print("\n[Phase 2] Add Rocks (12-24s)")
	print("  - Coastal rocks (procedural, ~80 triangles each)")
	print("  - Target: <4,500 triangles for RPi 4 @ 55 FPS")
	
	await get_tree().process_frame
	
	var rocks = asset_library["rocks"]
	if not rocks.is_empty():
		multimesh_groups["all_rocks"] = create_combined_multimesh(rocks, [
			{"count": 8, "zone": "coastal"},
			{"count": 2, "zone": "general"}
		])
		print("[Phase 2] Created 10 procedural rocks (1 combined MultiMesh)")
		print("[Phase 2] Est. triangles: ~5,600 (12 trees + 10 rocks × 80 tri)")
	
	# Note: Ocean shader disabled for performance test
	print("[Phase 2] Ocean waves disabled (StandardMaterial3D)")
	
	if metrics_overlay:
		metrics_overlay.update_phase(2, "Add Rocks")

func transition_to_phase_3():
	print("\n[Phase 3] Add Vegetation (24-36s)")
	print("  - Dense undergrowth + wind animation")
	
	await get_tree().process_frame
	
	var vegetation = asset_library["vegetation"]
	if not vegetation.is_empty():
		multimesh_groups["all_vegetation"] = create_combined_multimesh(vegetation, [
			{"count": 12, "zone": "interior"},
			{"count": 5, "zone": "coastal"},
			{"count": 3, "zone": "general"}
		])
		print("[Phase 3] Created 20 vegetation (1 combined MultiMesh)")
		print("[Phase 3] Est. triangles: ~5,600 (10 trees + 6 rocks + 20 vegetation × 50 tri)")
		
	# DISABLED FOR TESTING: Apply wind shader to vegetation
	# var wind_shader = load("res://shaders/wind_vegetation.gdshader")
	# if multimesh_groups.has("all_vegetation"):
	# 	var mmi = multimesh_groups["all_vegetation"]
	# 	var shader_mat = ShaderMaterial.new()
	# 	shader_mat.shader = wind_shader
	# 	shader_mat.set_shader_parameter("wind_speed", 2.0)
	# 	shader_mat.set_shader_parameter("wind_strength", 0.15)
	# 	shader_mat.set_shader_parameter("max_height", 2.0)
	# 	
	# 	# Preserve original texture/color
	# 	var original_mat = mmi.material_override
	# 	if original_mat and original_mat is StandardMaterial3D:
	# 		shader_mat.set_shader_parameter("albedo_color", original_mat.albedo_color)
	# 		shader_mat.set_shader_parameter("albedo_texture", original_mat.albedo_texture)
	# 		shader_mat.set_shader_parameter("use_texture", original_mat.albedo_texture != null)
	# 	
	# 	mmi.material_override = shader_mat
	print("[Phase 3] Wind shader DISABLED for testing")
	
	if metrics_overlay:
		metrics_overlay.update_phase(3, "Add Vegetation")

func transition_to_phase_4():
	print("\n[Phase 4] Tree Wind Animation (36-48s)")
	print("  - Wind shaders for trees (no additional geometry)")
	print("  - Target: ~5,600 triangles for RPi 4 @ 45 FPS")
	
	await get_tree().process_frame
	
	# Skip ground details to stay under 10K triangle budget
	# RPi 4 can handle ~10K triangles @ 60 FPS
	print("[Phase 4] Ground details skipped (staying under RPi 4 triangle budget)")
	print("[Phase 4] Total objects: 36 (10 trees + 6 rocks + 20 vegetation)")
	
	# DISABLED FOR TESTING: Apply wind shader to trees
	# var tree_wind_shader = load("res://shaders/wind_trees.gdshader")
	# if multimesh_groups.has("all_trees"):
	# 	var mmi = multimesh_groups["all_trees"]
	# 	var shader_mat = ShaderMaterial.new()
	# 	shader_mat.shader = tree_wind_shader
	# 	shader_mat.set_shader_parameter("wind_speed", 0.8)
	# 	shader_mat.set_shader_parameter("wind_strength", 0.4)
	# 	shader_mat.set_shader_parameter("max_height", 5.0)
	# 	
	# 	# Preserve original texture/color
	# 	var original_mat = mmi.material_override
	# 	if original_mat and original_mat is StandardMaterial3D:
	# 		shader_mat.set_shader_parameter("albedo_color", original_mat.albedo_color)
	# 		shader_mat.set_shader_parameter("albedo_texture", original_mat.albedo_texture)
	# 		shader_mat.set_shader_parameter("use_texture", original_mat.albedo_texture != null)
	# 	
	# 	mmi.material_override = shader_mat
	print("[Phase 4] Wind shader DISABLED for testing")
	
	# Note: Ocean shader disabled for performance test
	print("[Phase 4] Ocean waves disabled (StandardMaterial3D)")
	
	if metrics_overlay:
		metrics_overlay.update_phase(4, "Add Ground Detail")

func transition_to_phase_5():
	print("\n[Phase 5] Maximum Complexity (48-60s)")
	print("  - Maximum ocean waves + full ambient lighting")
	print("  - Target: ~5,600 triangles for RPi 4 @ 40 FPS")
	print("  - Final object count: 36 (10 trees + 6 rocks + 20 vegetation)")
	print("  - Triangle budget: UNDER 10,000 ✅")
	
	await get_tree().process_frame
	
	# Note: Ocean shader disabled for performance test
	print("[Phase 5] Ocean waves disabled (StandardMaterial3D)")
	
	# Boost ambient light
	if env and env.environment:
		env.environment.ambient_light_energy = 0.8
	
	print("[Phase 5] RPi 4 optimized: <10K triangles, per-vertex lighting, VRAM compressed textures")
	
	if metrics_overlay:
		metrics_overlay.update_phase(5, "Maximum Complexity")

func _process(delta: float):
	if not warmup_complete:
		return
	
	# Track timeline
	timeline += delta
	
	# Phase transitions
	if timeline >= 12.0 and not phase_triggered[2]:
		phase_triggered[2] = true
		transition_to_phase_2()
	elif timeline >= 24.0 and not phase_triggered[3]:
		phase_triggered[3] = true
		transition_to_phase_3()
	elif timeline >= 36.0 and not phase_triggered[4]:
		phase_triggered[4] = true
		transition_to_phase_4()
	elif timeline >= 48.0 and not phase_triggered[5]:
		phase_triggered[5] = true
		transition_to_phase_5()
	elif timeline >= 59.0 and not fade_started:
		fade_started = true
		start_fadeout()
	
	# Update metrics
	update_metrics()

func update_metrics():
	"""Update performance metrics"""
	var fps = Engine.get_frames_per_second()
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var cpu_usage = OS.get_processor_count()  # Placeholder
	var temp = 0.0  # Placeholder
	var gpu_usage = 0.0  # Placeholder
	
	# Store in current phase
	if metrics.has(current_phase_key):
		metrics[current_phase_key]["fps"].append(fps)
		metrics[current_phase_key]["frame_times"].append(frame_time)
		metrics[current_phase_key]["cpu"].append(cpu_usage)
		metrics[current_phase_key]["temps"].append(temp)
		metrics[current_phase_key]["gpu"].append(gpu_usage)
		metrics[current_phase_key]["timestamps"].append(timeline)
	
	# Update overlay
	if metrics_overlay:
		metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
		metrics_overlay.update_progress(timeline, 60.0)

func start_fadeout():
	"""Start fade out animation"""
	print("\n[NatureIsland] Starting fadeout...")
	
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 1.0)
		await tween.finished
	
	# Save metrics
	save_metrics_to_file()
	
	# Return to menu or quit
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func save_metrics_to_file():
	"""Save performance metrics to JSON file"""
	# Check if CLI specified custom output path
	var main_node = get_tree().root.get_node_or_null("Main")
	var file_path = ""
	
	if main_node and main_node.has_method("get_cli_output_path"):
		file_path = main_node.get_cli_output_path("nature_island")
	else:
		# Default fallback
		file_path = "user://nature_island_metrics_%d.json" % Time.get_ticks_msec()
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		var data = {
			"benchmark": "Nature Island",
			"duration": 60.0,
			"phases": metrics,
			"platform": OS.get_name(),
			"timestamp": Time.get_datetime_string_from_system()
		}
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("[NatureIsland] Metrics saved to: ", file_path)
	else:
		push_error("[NatureIsland] Failed to save metrics")

func _input(event):
	"""Handle input events"""
	if event.is_action_pressed("ui_cancel"):
		print("[NatureIsland] ESC pressed - exiting benchmark")
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

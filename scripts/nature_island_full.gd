extends Node3D

## Nature Island Benchmark - Realistic Forested Island
## 100-120 trees, ocean, cinematic camera, MultiMesh optimized
## Target: 60 FPS desktop Phase 1

# Node references
@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var env: WorldEnvironment = $WorldEnvironment
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var metrics_overlay = $MetricsOverlay
@onready var fade_overlay = $FadeOverlay
@onready var ocean: MeshInstance3D = $Ocean

# Asset library (loaded at startup)
var asset_library = {
	"trees": [],
	"rocks": [],
	"vegetation": [],
	"ground": [],
	"coastal": []
}

# MultiMesh instances (created at runtime)
var multimesh_groups = {}

# Timeline and phase tracking
var timeline: float = 0.0
var current_phase: int = 0
var phase_triggered: Array = [false, false, false, false, false, false]

# Island layout constants
const ISLAND_CENTER = Vector3(0, 0, 0)
const ISLAND_SIZE_X = 50.0  # 50m x 35m irregular shape
const ISLAND_SIZE_Z = 35.0
const OCEAN_SIZE = 200.0

# Object counts (optimized for Raspberry Pi SBC - 40% further reduction for close-range)
const TREE_COUNT = 30
const ROCK_COUNT = 12
const VEGETATION_COUNT = 25
const GROUND_DETAIL_COUNT = 30
const FLOWER_COUNT = 10

# Performance monitoring
var loading_progress = 0.0
var is_loading = true
var perf_monitor: PerformanceMonitor
var last_fps: float = 60.0
var last_frame_time: float = 16.6
var last_cpu: float = 0.0
var last_temp: float = 0.0
var last_gpu: float = 0.0

func _ready():
	print("[NatureIsland] Initializing realistic forested island benchmark...")
	print("[NatureIsland] Creating optimized primitive meshes for Raspberry Pi SBC...")
	
	# Get performance monitor from Main scene or create standalone
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.perf_monitor:
		perf_monitor = main.perf_monitor
		print("[NatureIsland] Using performance monitor from Main")
	else:
		print("[NatureIsland] Creating standalone performance monitor")
		perf_monitor = PerformanceMonitor.new()
	
	# Load all assets first
	load_all_assets()
	
	# Start with Phase 1
	setup_phase_1()
	
	# Start audio
	audio.play()
	print("[NatureIsland] Audio started, duration: %.1fs" % audio.stream.get_length())
	
	is_loading = false

func _process(delta: float):
	if is_loading:
		return
	
	timeline += delta
	
	# Phase transitions
	if timeline >= 35.0 and not phase_triggered[1]:
		phase_triggered[1] = true
		transition_to_phase_2()
	elif timeline >= 70.0 and not phase_triggered[2]:
		phase_triggered[2] = true
		transition_to_phase_3()
	elif timeline >= 105.0 and not phase_triggered[3]:
		phase_triggered[3] = true
		transition_to_phase_4()
	elif timeline >= 140.0 and not phase_triggered[4]:
		phase_triggered[4] = true
		transition_to_phase_5()
	elif timeline >= 171.0 and not phase_triggered[5]:
		phase_triggered[5] = true
		start_fadeout()
	
	# Update metrics overlay
	update_metrics()

func load_all_assets():
	"""Create optimized primitive meshes for Raspberry Pi SBC"""
	print("[NatureIsland] Creating optimized primitive meshes for SBC...")
	
	# Create 3 tree variants (different colors)
	for i in range(3):
		asset_library["trees"].append(create_primitive_mesh("tree", i))
	
	# Create 3 rock variants (different colors)
	for i in range(3):
		asset_library["rocks"].append(create_primitive_mesh("rock", i))
	
	# Create 3 vegetation variants (different colors)
	for i in range(3):
		asset_library["vegetation"].append(create_primitive_mesh("vegetation", i))
	
	# Create 2 ground variants (different shades)
	for i in range(2):
		asset_library["ground"].append(create_primitive_mesh("ground", i))
	
	# Create 1 coastal variant (same as rocks)
	asset_library["coastal"].append(create_primitive_mesh("rock", 0))
	
	print("[NatureIsland] Created primitive meshes: Trees=%d, Rocks=%d, Vegetation=%d, Ground=%d, Coastal=%d" %
		[asset_library["trees"].size(), asset_library["rocks"].size(), 
		asset_library["vegetation"].size(), asset_library["ground"].size(), 
		asset_library["coastal"].size()])

func create_primitive_mesh(type: String, variant: int = 0) -> Dictionary:
	"""Create optimized primitive mesh for Raspberry Pi SBC performance"""
	var mesh = null
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_BACK
	
	match type:
		"tree":
			# Simple tree (sphere canopy - trunk handled by transform scaling)
			var canopy = SphereMesh.new()
			canopy.radius = 2.0
			canopy.height = 3.0
			canopy.radial_segments = 6
			canopy.rings = 3
			
			# Color variation
			var green_variants = [
				Color(0.2, 0.5, 0.2),   # Dark green
				Color(0.3, 0.6, 0.3),   # Medium green
				Color(0.25, 0.55, 0.25) # Light-medium green
			]
			material.albedo_color = green_variants[variant % 3]
			mesh = canopy
		
		"rock":
			# Simple rock (low-poly sphere with irregular look)
			var rock_mesh = SphereMesh.new()
			rock_mesh.radius = 1.0
			rock_mesh.radial_segments = 5
			rock_mesh.rings = 3
			
			# Color variation
			var rock_variants = [
				Color(0.5, 0.5, 0.5),   # Gray
				Color(0.4, 0.4, 0.45),  # Blue-gray
				Color(0.45, 0.42, 0.4)  # Brown-gray
			]
			material.albedo_color = rock_variants[variant % 3]
			mesh = rock_mesh
		
		"vegetation":
			# Simple vegetation (small sphere)
			var veg_mesh = SphereMesh.new()
			veg_mesh.radius = 0.5
			veg_mesh.radial_segments = 5
			veg_mesh.rings = 3
			
			# Color variation
			var veg_variants = [
				Color(0.3, 0.6, 0.2),   # Bright green
				Color(0.4, 0.65, 0.3),  # Yellow-green
				Color(0.35, 0.55, 0.25) # Medium green
			]
			material.albedo_color = veg_variants[variant % 3]
			mesh = veg_mesh
		
		"ground":
			# Ground texture (flat plane)
			var ground_mesh = PlaneMesh.new()
			ground_mesh.size = Vector2(2.0, 2.0)
			
			# Color variation
			var ground_variants = [
				Color(0.4, 0.3, 0.2),  # Brown
				Color(0.35, 0.28, 0.18) # Darker brown
			]
			material.albedo_color = ground_variants[variant % 2]
			mesh = ground_mesh
		
		_:
			# Default fallback
			var default_mesh = BoxMesh.new()
			default_mesh.size = Vector3(1, 1, 1)
			material.albedo_color = Color(0.8, 0.8, 0.8)
			mesh = default_mesh
	
	return {"mesh": mesh, "material": material}

func create_multimesh_from_assets(asset_list: Array, instance_count: int, zone: String) -> MultiMeshInstance3D:
	"""Create MultiMesh from list of primitive mesh assets"""
	if asset_list.is_empty() or instance_count == 0:
		return null
	
	var mmi = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	
	# Use first asset (now a Dictionary with "mesh" and "material")
	var base_data = asset_list[0]
	if not base_data.has("mesh") or not base_data["mesh"]:
		return null
	
	multimesh.mesh = base_data["mesh"]
	mmi.multimesh = multimesh
	
	# Add visibility range for automatic distance culling (Raspberry Pi optimization)
	mmi.visibility_range_begin = 0.0
	mmi.visibility_range_end = 40.0  # Fade out beyond 40m
	mmi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	
	# Apply material (already optimized in primitive creation)
	if base_data.has("material") and base_data["material"]:
		mmi.material_override = base_data["material"]
	
	# Detect if this is a ground texture based on mesh type
	var is_ground = base_data["mesh"] is PlaneMesh
	
	# Generate transforms based on zone and asset type
	var transforms = generate_transforms_for_zone(instance_count, zone, is_ground)
	for i in range(instance_count):
		multimesh.set_instance_transform(i, transforms[i])
	
	add_child(mmi)
	return mmi

func generate_transforms_for_zone(count: int, zone: String, is_ground_texture: bool = false) -> Array[Transform3D]:
	"""Generate transforms based on island zone (no collision checking for performance)"""
	var transforms: Array[Transform3D] = []
	
	for i in range(count):
		var transform = Transform3D()
		var pos = Vector3.ZERO
		
		if zone == "interior_forest":
			# Central dense forest
			pos = Vector3(
				randf_range(-15, 15),
				0,
				randf_range(-10, 10)
			)
		elif zone == "coastal":
			# Coastal ring
			var angle = randf() * TAU
			var radius = randf_range(18, 25)
			pos = Vector3(
				cos(angle) * radius,
				0,
				sin(angle) * radius
			)
		elif zone == "clearing":
			# Scattered clearings
			var clearing_center = Vector3(randf_range(-10, 10), 0, randf_range(-8, 8))
			pos = clearing_center + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
		else:
			# General scattered
			pos = Vector3(
				randf_range(-ISLAND_SIZE_X/2, ISLAND_SIZE_X/2),
				0,
				randf_range(-ISLAND_SIZE_Z/2, ISLAND_SIZE_Z/2)
			)
		
		if is_ground_texture:
			# Flatten for ground textures (lie flat on XZ plane)
			transform = transform.rotated(Vector3.RIGHT, -PI/2)  # Rotate to lie flat
			var scale_xy = randf_range(2.0, 4.0)
			transform = transform.scaled(Vector3(scale_xy, 0.1, scale_xy))
			pos.y = 0.01  # Slightly above ground to avoid z-fighting
		else:
			# Normal 3D object (trees, rocks, plants)
			transform = transform.rotated(Vector3.UP, randf() * TAU)
			var scale = randf_range(0.8, 1.3)
			transform = transform.scaled(Vector3(scale, scale, scale))
			pos.y = max(0, pos.y)  # Ensure on ground (no floating)
		
		transform.origin = pos
		transforms.append(transform)
	
	return transforms

func setup_phase_1():
	"""Phase 1: Trees + Ocean (0-35s) - Target 60 FPS"""
	current_phase = 1
	print("\n[NatureIsland] === PHASE 1: Dense Forest + Ocean (0-35s) ===")
	
	# Disable shadows for maximum performance
	sun.shadow_enabled = false
	sun.light_energy = 1.0
	
	# Simple environment
	if env.environment:
		env.environment.background_mode = Environment.BG_SKY
		env.environment.fog_enabled = false
		env.environment.glow_enabled = false
		env.environment.volumetric_fog_enabled = false
	
	# Create tree MultiMeshes (all trees use same asset for batching)
	var all_trees = asset_library["trees"]
	
	if not all_trees.is_empty():
		multimesh_groups["large_trees"] = create_multimesh_from_assets(all_trees, 20, "interior_forest")
		print("[NatureIsland] Created 20 large trees")
		
		multimesh_groups["small_trees"] = create_multimesh_from_assets(all_trees, 7, "coastal")
		print("[NatureIsland] Created 7 small trees")
		
		multimesh_groups["saplings"] = create_multimesh_from_assets(all_trees, 3, "clearing")
		print("[NatureIsland] Created 3 saplings")
	
	# Setup simple ocean (Phase 1: just color + basic UV scroll)
	setup_ocean_phase_1()
	
	update_metrics_overlay("Phase 1: Dense Forest + Ocean", "Trees: 30 | Draw Calls: ~4 | Target: 70 FPS")

func setup_ocean_phase_1():
	"""Setup simple ocean for Phase 1"""
	if not ocean:
		return
	
	var mat = ocean.get_surface_override_material(0)
	if mat and mat is ShaderMaterial:
		# Enable simple water shader
		mat.set_shader_parameter("phase", 1)
		mat.set_shader_parameter("wave_speed", 0.5)
		mat.set_shader_parameter("wave_height", 0.0)  # No waves in Phase 1

func transition_to_phase_2():
	"""Phase 2: + Rocks (35-70s) - Target 55 FPS"""
	current_phase = 2
	print("\n[NatureIsland] === PHASE 2: + Rocks (35-70s) ===")
	
	# Add rock MultiMeshes
	var all_rocks = asset_library["rocks"]
	
	if not all_rocks.is_empty():
		multimesh_groups["boulders"] = create_multimesh_from_assets(all_rocks, 5, "coastal")
		print("[NatureIsland] Created 5 boulders")
		
		multimesh_groups["rock_faces"] = create_multimesh_from_assets(all_rocks, 4, "coastal")
		print("[NatureIsland] Created 4 rock faces")
		
		multimesh_groups["small_rocks"] = create_multimesh_from_assets(all_rocks, 3, "general")
		print("[NatureIsland] Created 3 small rocks")
	
	# Animate ocean
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("wave_height", 0.3)
	
	update_metrics_overlay("Phase 2: + Rocks", "Objects: 42 | Draw Calls: ~7 | Target: 70 FPS")

func transition_to_phase_3():
	"""Phase 3: + Vegetation (70-105s) - Target 50 FPS"""
	current_phase = 3
	print("\n[NatureIsland] === PHASE 3: + Vegetation (70-105s) ===")
	
	# Add vegetation MultiMeshes
	var all_vegetation = asset_library["vegetation"]
	
	if not all_vegetation.is_empty():
		multimesh_groups["shrubs"] = create_multimesh_from_assets(all_vegetation, 10, "clearing")
		print("[NatureIsland] Created 10 shrubs")
		
		multimesh_groups["grasses"] = create_multimesh_from_assets(all_vegetation, 8, "general")
		print("[NatureIsland] Created 8 grasses")
		
		multimesh_groups["flowers"] = create_multimesh_from_assets(all_vegetation, 5, "clearing")
		print("[NatureIsland] Created 5 flowers")
		
		multimesh_groups["plants"] = create_multimesh_from_assets(all_vegetation, 2, "interior_forest")
		print("[NatureIsland] Created 2 plants")
	
	# Add foam to water
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 3)
	
	update_metrics_overlay("Phase 3: + Vegetation", "Objects: 67 | Draw Calls: ~11 | Target: 70 FPS")

func transition_to_phase_4():
	"""Phase 4: + Ground Detail + Lighting (105-140s) - Target 45 FPS"""
	current_phase = 4
	print("\n[NatureIsland] === PHASE 4: + Ground Detail + Lighting (105-140s) ===")
	
	# Split ground assets into textures (flat) and 3D objects
	var ground_textures = []
	var ground_3d_objects = []
	
	for asset in asset_library["ground"]:
		if is_ground_texture_asset(asset.resource_path):
			ground_textures.append(asset)
		else:
			ground_3d_objects.append(asset)
	
	# Add coastal assets (these are 3D features)
	var coastal_assets = asset_library["coastal"]
	
	# Place ground textures FLAT
	if not ground_textures.is_empty():
		multimesh_groups["ground_textures"] = create_multimesh_from_assets(ground_textures, 20, "general")
		print("[NatureIsland] Created 20 ground texture patches (flat)")
	
	# Place 3D ground objects normally (roots, coastal features)
	if not ground_3d_objects.is_empty():
		multimesh_groups["roots"] = create_multimesh_from_assets(ground_3d_objects, 8, "interior_forest")
		print("[NatureIsland] Created 8 root clusters")
	
	if not coastal_assets.is_empty():
		multimesh_groups["coastal_features"] = create_multimesh_from_assets(coastal_assets, 2, "coastal")
		print("[NatureIsland] Created 2 coastal features")
	
	# Enable per-vertex lighting
	for group_name in multimesh_groups:
		var mmi = multimesh_groups[group_name]
		if mmi and mmi.material_override:
			var mat = mmi.material_override
			if mat is StandardMaterial3D:
				mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	
	# Enhanced water
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 4)
		mat.set_shader_parameter("wave_height", 0.5)
	
	update_metrics_overlay("Phase 4: + Ground + Lighting", "Objects: 140 | Draw Calls: ~15 | Target: 45 FPS")

func transition_to_phase_5():
	"""Phase 5: Per-Vertex Lighting Only (140-176s) - Target 40 FPS (NO shadows/glow for Raspberry Pi)"""
	current_phase = 5
	print("\n[NatureIsland] === PHASE 5: Per-Vertex Lighting (140-176s) ===")
	
	# Keep shadows disabled for Raspberry Pi performance
	sun.shadow_enabled = false
	print("[NatureIsland] Shadows disabled for Raspberry Pi optimization")
	
	# Keep glow disabled for Raspberry Pi performance
	if env.environment:
		env.environment.glow_enabled = false
	print("[NatureIsland] Glow disabled for Raspberry Pi optimization")
	
	# Full water shader (but still no expensive vertex displacement in early phases)
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 5)
		mat.set_shader_parameter("wave_height", 0.8)
	
	update_metrics_overlay("Phase 5: Per-Vertex Lighting", "Objects: 140+ | Draw Calls: ~15 | Target: 40 FPS")

func start_fadeout():
	"""Fade to black at the end (171-176s)"""
	print("[NatureIsland] Starting final fadeout...")
	
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 5.0)
	tween.tween_callback(end_benchmark)

func end_benchmark():
	"""Return to main menu"""
	print("[NatureIsland] Benchmark complete!")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func update_metrics():
	"""Update performance metrics display in real-time"""
	if not metrics_overlay:
		return
	
	# Update performance monitor if available
	if perf_monitor:
		perf_monitor.update(get_process_delta_time())
		
		# Get current metrics
		last_fps = perf_monitor.get_current_fps()
		last_frame_time = perf_monitor.get_current_frametime_ms()
		last_cpu = perf_monitor.get_cpu_usage()
		last_temp = perf_monitor.get_temperature()
		last_gpu = perf_monitor.get_gpu_usage()
	else:
		# Fallback metrics if no perf monitor
		last_fps = Engine.get_frames_per_second()
		last_frame_time = get_process_delta_time() * 1000.0
		last_cpu = 0.0
		last_temp = 0.0
		last_gpu = 0.0
	
	# Update metrics overlay
	if metrics_overlay.has_method("update_metrics"):
		metrics_overlay.update_metrics(last_fps, last_frame_time, last_cpu, last_temp, last_gpu)
	
	# Update progress bar
	if metrics_overlay.has_method("update_progress"):
		metrics_overlay.update_progress(timeline, 176.0)

func update_metrics_overlay(phase_name: String, details: String):
	"""Update the metrics overlay with phase information"""
	if metrics_overlay and metrics_overlay.has_method("update_phase"):
		metrics_overlay.update_phase(current_phase, phase_name)

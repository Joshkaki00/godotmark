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
const OCEAN_SIZE = 80.0  # Reduced from 200 to 80 for performance

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

func run_warmup_phase(loading_screen):
	"""Pre-compile all shaders and create GPU buffers"""
	print("[NatureIsland] Starting warmup phase...")
	
	# Make everything visible to force shader compilation
	camera.current = true
	sun.visible = true
	ocean.visible = true
	
	if loading_screen:
		loading_screen.update_progress(75.0, "Compiling ocean shader...")
	
	# Force compile ocean shader with all phase variants
	if ocean:
		var mat = ocean.get_surface_override_material(0)
		if mat and mat is ShaderMaterial:
			# Cycle through all phase parameters to compile variants
			for phase_num in [1, 2, 3, 4, 5]:
				mat.set_shader_parameter("phase", phase_num)
				await get_tree().process_frame
			mat.set_shader_parameter("phase", 1)  # Reset to phase 1
			print("[NatureIsland] Ocean shader variants compiled")
	
	if loading_screen:
		loading_screen.update_progress(80.0, "Compiling wind shaders...")
	
	# Force compile wind shaders by making MultiMeshes visible
	# The shaders will compile when first rendered
	for group_name in multimesh_groups:
		var mmi = multimesh_groups[group_name]
		if mmi:
			mmi.visible = true
	
	# Render multiple frames to ensure GPU buffers created
	for i in range(10):
		if loading_screen:
			loading_screen.update_progress(80.0 + i, "Rendering test frames... %d/10" % (i+1))
		await get_tree().process_frame
	
	print("[NatureIsland] GPU buffers created - rendered 10 test frames")
	
	if loading_screen:
		loading_screen.update_progress(95.0, "Thermal stabilization...")
	
	# Thermal stabilization (60 frames = 1 second @ 60 FPS)
	for i in range(60):
		await get_tree().process_frame
	
	print("[NatureIsland] Warmup complete!")

func _ready():
	print("[NatureIsland] Initializing realistic forested island benchmark...")
	
	# Force disable VSync for accurate benchmark
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("[NatureIsland] VSync forcibly disabled")
	
	# Hide everything during warmup
	camera.current = false
	if metrics_overlay:
		metrics_overlay.visible = false
	
	# Show loading screen
	var loading_screen = get_node_or_null("LoadingScreen")
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Initializing systems...")
	
	await get_tree().process_frame
	
	# Set benchmark title in overlay
	if metrics_overlay and metrics_overlay.has_method("set_benchmark_title"):
		metrics_overlay.set_benchmark_title("NATURE ISLAND BENCHMARK")
	
	# Get performance monitor from Main scene or create standalone
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.perf_monitor:
		perf_monitor = main.perf_monitor
		print("[NatureIsland] Using performance monitor from Main")
	else:
		print("[NatureIsland] Creating standalone performance monitor")
		perf_monitor = PerformanceMonitor.new()
	
	if loading_screen:
		loading_screen.update_progress(10.0, "Loading assets...")
	
	# Load all assets asynchronously to prevent freeze
	await load_all_assets_async()
	
	if loading_screen:
		loading_screen.update_progress(50.0, "Creating scene...")
	
	# Start with Phase 1 (also async to prevent freeze during MultiMesh creation)
	await setup_phase_1_async()
	
	if loading_screen:
		loading_screen.update_progress(70.0, "Pre-compiling shaders...")
	
	# NEW: Warmup phase - pre-compile all shaders
	await run_warmup_phase(loading_screen)
	
	# Hide loading screen, show scene
	if loading_screen:
		loading_screen.visible = false
	camera.current = true
	if metrics_overlay:
		metrics_overlay.visible = true
	
	# Loading complete - NOW start audio and benchmark
	is_loading = false
	print("[NatureIsland] Loading complete! Starting benchmark...")
	
	# Start audio
	audio.play()
	print("[NatureIsland] Audio started, duration: %.1fs" % audio.stream.get_length())

func _process(delta: float):
	if is_loading:
		return
	
	# Profile rendering pipeline for diagnostics
	profile_rendering_pipeline(delta)
	
	# Diagnostic: Log slow frames
	var frame_ms = delta * 1000.0
	if frame_ms > 50.0:  # Slower than 20 FPS
		push_warning("[NatureIsland] SLOW FRAME: %.1fms (%.1f FPS)" % [frame_ms, 1.0/delta])
	
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

func load_and_extract_gltf(path: String) -> Dictionary:
	"""Load GLTF, extract mesh, create pre-cached materials"""
	var gltf_document = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	var error = gltf_document.append_from_file(path, gltf_state)
	
	if error != OK:
		push_error("[NatureIsland] Failed to load GLTF: " + path)
		return {}
	
	var scene = gltf_document.generate_scene(gltf_state)
	var mesh_instance = find_mesh_instance_recursive(scene)
	
	if not mesh_instance:
		push_error("[NatureIsland] No MeshInstance3D found in: " + path)
		# Cleanup before returning
		for child in scene.get_children():
			scene.remove_child(child)
			child.queue_free()
		scene.queue_free()
		return {}
	
	var mesh = mesh_instance.mesh
	
	# Get original material or create default
	var original_mat = null
	if mesh_instance.get_surface_override_material_count() > 0:
		original_mat = mesh_instance.get_surface_override_material(0)
	if not original_mat and mesh.get_surface_count() > 0:
		original_mat = mesh.surface_get_material(0)
	
	# Create unshaded version (Phase 1-4)
	var mat_unshaded = StandardMaterial3D.new()
	mat_unshaded.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_unshaded.cull_mode = BaseMaterial3D.CULL_BACK
	if original_mat and original_mat is StandardMaterial3D:
		mat_unshaded.albedo_color = original_mat.albedo_color
		# Check if texture loaded successfully (compressed texture errors result in invalid textures)
		if original_mat.albedo_texture:
			var tex = original_mat.albedo_texture
			if tex is Texture2D:
				# Verify texture is valid (non-zero size means it loaded)
				var img = tex.get_image()
				if img and img.get_size() != Vector2i(0, 0):
					mat_unshaded.albedo_texture = tex
				# else: Texture failed to load, skip it (use solid color)
	else:
		mat_unshaded.albedo_color = Color(0.8, 0.8, 0.8)
	
	# Create lit version (Phase 5)
	var mat_lit = StandardMaterial3D.new()
	mat_lit.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat_lit.cull_mode = BaseMaterial3D.CULL_BACK
	if original_mat and original_mat is StandardMaterial3D:
		mat_lit.albedo_color = original_mat.albedo_color
		# Check albedo texture
		if original_mat.albedo_texture:
			var tex = original_mat.albedo_texture
			if tex is Texture2D:
				var img = tex.get_image()
				if img and img.get_size() != Vector2i(0, 0):
					mat_lit.albedo_texture = tex
		# Check normal texture
		if original_mat.normal_texture:
			var tex = original_mat.normal_texture
			if tex is Texture2D:
				var img = tex.get_image()
				if img and img.get_size() != Vector2i(0, 0):
					mat_lit.normal_texture = tex
	else:
		mat_lit.albedo_color = Color(0.8, 0.8, 0.8)
	
	# Properly cleanup GLTF scene to prevent memory leaks
	# Free all children recursively
	for child in scene.get_children():
		scene.remove_child(child)
		child.queue_free()
	scene.queue_free()
	
	return {
		"mesh": mesh,
		"material_unshaded": mat_unshaded,
		"material_lit": mat_lit,
		"source_path": path
	}

func find_mesh_instance_recursive(node: Node) -> MeshInstance3D:
	"""Recursively find first MeshInstance3D in scene tree"""
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_mesh_instance_recursive(child)
		if result:
			return result
	return null

func is_ground_asset(asset_data: Dictionary) -> bool:
	"""Detect if GLTF asset should be flattened as ground texture"""
	if not asset_data.has("mesh"):
		return false
	
	var mesh = asset_data["mesh"]
	
	# PlaneMesh check (for primitives, if any remain)
	if mesh is PlaneMesh:
		return true
	
	# GLTF mesh name/path check
	# Ground assets typically have "ground", "mud", "trail" in their paths
	if asset_data.has("source_path"):
		var path = asset_data["source_path"].to_lower()
		return ("ground" in path or "mud" in path or "trail" in path or 
				"coast_line" in path or "rocky_trail" in path)
	
	return false

func load_all_assets_async():
	"""Load 1K GLTF assets asynchronously with performance optimizations"""
	print("[NatureIsland] Loading 1K GLTF assets for realistic forested island (async)...")
	
	# Trees (use 3 island trees for variety)
	var tree_paths = [
		"res://art/nature-benchmark/island_tree_01_1k.gltf/island_tree_01_1k.gltf",
		"res://art/nature-benchmark/island_tree_02_1k.gltf/island_tree_02_1k.gltf",
		"res://art/nature-benchmark/island_tree_03_1k.gltf/island_tree_03_1k.gltf"
	]
	for path in tree_paths:
		var gltf_data = load_and_extract_gltf(path)
		if gltf_data:
			asset_library["trees"].append(gltf_data)
		await get_tree().process_frame
	
	# Rocks (use 3 coast rock variants)
	var rock_paths = [
		"res://art/nature-benchmark/boulder_01_1k.gltf/boulder_01_1k.gltf",
		"res://art/nature-benchmark/coast_rocks_01_1k.gltf/coast_rocks_01_1k.gltf",
		"res://art/nature-benchmark/coast_rocks_02_1k.gltf/coast_rocks_02_1k.gltf"
	]
	for path in rock_paths:
		var gltf_data = load_and_extract_gltf(path)
		if gltf_data:
			asset_library["rocks"].append(gltf_data)
		await get_tree().process_frame
	
	# Vegetation - Shrubs (2 types)
	var shrub_paths = [
		"res://art/nature-benchmark/shrub_01_1k.gltf/shrub_01_1k.gltf",
		"res://art/nature-benchmark/wild_rooibos_bush_1k.gltf/wild_rooibos_bush_1k.gltf"
	]
	for path in shrub_paths:
		var gltf_data = load_and_extract_gltf(path)
		if gltf_data:
			asset_library["vegetation"].append(gltf_data)
		await get_tree().process_frame
	
	# Vegetation - Plants (2 types)
	var plant_paths = [
		"res://art/nature-benchmark/fern_02_1k.gltf/fern_02_1k.gltf",
		"res://art/nature-benchmark/nettle_plant_1k.gltf/nettle_plant_1k.gltf"
	]
	for path in plant_paths:
		var gltf_data = load_and_extract_gltf(path)
		if gltf_data:
			asset_library["vegetation"].append(gltf_data)
		await get_tree().process_frame
	
	# Ground textures (2 types)
	var ground_paths = [
		"res://art/nature-benchmark/forest_ground_04_1k.gltf/forest_ground_04_1k.gltf",
		"res://art/nature-benchmark/brown_mud_1k.gltf/brown_mud_1k.gltf"
	]
	for path in ground_paths:
		var gltf_data = load_and_extract_gltf(path)
		if gltf_data:
			asset_library["ground"].append(gltf_data)
		await get_tree().process_frame
	
	# Coastal (use same rocks for coastal)
	if not asset_library["rocks"].is_empty():
		asset_library["coastal"].append(asset_library["rocks"][0])
	
	print("[NatureIsland] Loaded GLTF assets: Trees=%d, Rocks=%d, Vegetation=%d, Ground=%d, Coastal=%d" %
		[asset_library["trees"].size(), asset_library["rocks"].size(), 
		asset_library["vegetation"].size(), asset_library["ground"].size(), 
		asset_library["coastal"].size()])

func create_multimesh_from_assets(asset_list: Array, instance_count: int, zone: String) -> MultiMeshInstance3D:
	"""Create MultiMesh from list of GLTF assets"""
	if asset_list.is_empty() or instance_count == 0:
		return null
	
	var mmi = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	
	# Use first asset (Dictionary with "mesh", "material_unshaded", "material_lit")
	var base_data = asset_list[0]
	if not base_data.has("mesh") or not base_data["mesh"]:
		return null
	
	multimesh.mesh = base_data["mesh"]
	mmi.multimesh = multimesh
	
	# Add visibility range for automatic distance culling (Raspberry Pi optimization)
	mmi.visibility_range_begin = 0.0
	mmi.visibility_range_end = 40.0  # Fade out beyond 40m
	mmi.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	
	# Apply unshaded material (Phase 1-4 default)
	if base_data.has("material_unshaded") and base_data["material_unshaded"]:
		mmi.material_override = base_data["material_unshaded"]
	
	# Detect if this is a ground texture using new GLTF-aware function
	var is_ground = is_ground_asset(base_data)
	
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

func setup_phase_1_async():
	"""Phase 1: Trees + Ocean (0-35s) - Target 60 FPS (async to prevent loading freeze)"""
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
		await get_tree().process_frame  # Yield to prevent freeze
		
		multimesh_groups["small_trees"] = create_multimesh_from_assets(all_trees, 7, "coastal")
		print("[NatureIsland] Created 7 small trees")
		await get_tree().process_frame
		
		multimesh_groups["saplings"] = create_multimesh_from_assets(all_trees, 3, "clearing")
		print("[NatureIsland] Created 3 saplings")
		await get_tree().process_frame
	
	# Setup simple ocean (Phase 1: just color + basic UV scroll)
	setup_ocean_phase_1()
	
	update_metrics_overlay("Dense Forest + Ocean", "Trees: 30 | Draw Calls: ~4 | Target: 70 FPS")

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
	
	update_metrics_overlay("+ Rocks", "Objects: 42 | Draw Calls: ~7 | Target: 70 FPS")

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
	
	# Add wind animation to vegetation (GPU-based, zero CPU overhead)
	var wind_shader = load("res://shaders/wind_vegetation.gdshader")
	for group_name in ["shrubs", "grasses", "flowers", "plants"]:
		if multimesh_groups.has(group_name):
			var mmi = multimesh_groups[group_name]
			var shader_mat = ShaderMaterial.new()
			shader_mat.shader = wind_shader
			shader_mat.set_shader_parameter("wind_speed", 2.0)
			shader_mat.set_shader_parameter("wind_strength", 0.15)
			shader_mat.set_shader_parameter("max_height", 2.0)
			
			# Preserve original texture/color from GLTF asset
			var original_mat = mmi.material_override
			if original_mat and original_mat is StandardMaterial3D:
				shader_mat.set_shader_parameter("albedo_color", original_mat.albedo_color)
				shader_mat.set_shader_parameter("albedo_texture", original_mat.albedo_texture)
				shader_mat.set_shader_parameter("use_texture", original_mat.albedo_texture != null)
			
			mmi.material_override = shader_mat
	
	print("[NatureIsland] Applied wind animation shader to vegetation")
	
	# Add foam to water
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 3)
	
	update_metrics_overlay("+ Vegetation", "Objects: 67 | Draw Calls: ~11 | Target: 70 FPS")

func transition_to_phase_4():
	"""Phase 4: + Ground Detail + Lighting (105-140s) - Target 45 FPS"""
	current_phase = 4
	print("\n[NatureIsland] === PHASE 4: + Ground Detail + Lighting (105-140s) ===")
	
	# Split ground assets into textures (flat) and 3D objects using GLTF-aware detection
	var ground_textures = []
	var ground_3d_objects = []
	
	for asset in asset_library["ground"]:
		# Use new is_ground_asset() function that checks path names
		if is_ground_asset(asset):
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
	
	# Enhanced water
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 4)
		mat.set_shader_parameter("wave_height", 0.5)
	
	# Add wind animation to trees (GPU-based, zero CPU overhead)
	var tree_wind_shader = load("res://shaders/wind_trees.gdshader")
	for group_name in ["large_trees", "small_trees", "saplings"]:
		if multimesh_groups.has(group_name):
			var mmi = multimesh_groups[group_name]
			var shader_mat = ShaderMaterial.new()
			shader_mat.shader = tree_wind_shader
			shader_mat.set_shader_parameter("wind_speed", 0.8)
			shader_mat.set_shader_parameter("wind_strength", 0.4)
			shader_mat.set_shader_parameter("max_height", 5.0)
			
			# Preserve original texture/color from GLTF asset
			var original_mat = mmi.material_override
			if original_mat and original_mat is StandardMaterial3D:
				shader_mat.set_shader_parameter("albedo_color", original_mat.albedo_color)
				shader_mat.set_shader_parameter("albedo_texture", original_mat.albedo_texture)
				shader_mat.set_shader_parameter("use_texture", original_mat.albedo_texture != null)
			
			mmi.material_override = shader_mat
	
	print("[NatureIsland] Applied wind animation shader to trees")
	
	update_metrics_overlay("+ Ground + Lighting", "Objects: 140 | Draw Calls: ~15 | Target: 45 FPS")

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
	
	# Swap to pre-created per-vertex materials (NO shader recompilation freeze!)
	print("[NatureIsland] Swapping to per-vertex materials...")
	swap_to_lit_materials()
	
	# Full water shader (but still no expensive vertex displacement in early phases)
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 5)
		mat.set_shader_parameter("wave_height", 0.8)
	
	update_metrics_overlay("Per-Vertex Lighting", "Objects: 140+ | Draw Calls: ~15 | Target: 40 FPS")

func swap_to_lit_materials():
	"""Swap all multimesh materials to per-vertex lighting while preserving wind animation"""
	# Get original asset data with pre-created lit materials
	var asset_type_map = {
		"large_trees": "trees",
		"small_trees": "trees",
		"saplings": "trees",
		"boulders": "rocks",
		"rock_faces": "rocks",
		"small_rocks": "rocks",
		"shrubs": "vegetation",
		"grasses": "vegetation",
		"flowers": "vegetation",
		"plants": "vegetation",
		"ground_textures": "ground",
		"roots": "ground",
		"coastal_features": "coastal"
	}
	
	# Load wind shaders (if they exist)
	var tree_wind_shader = load("res://shaders/wind_trees.gdshader")
	var veg_wind_shader = load("res://shaders/wind_vegetation.gdshader")
	
	for group_name in multimesh_groups:
		var mmi = multimesh_groups[group_name]
		if not mmi:
			continue
		
		# Check if this group has wind animation
		var has_wind_shader = false
		var current_mat = mmi.material_override
		if current_mat and current_mat is ShaderMaterial:
			if current_mat.shader == tree_wind_shader or current_mat.shader == veg_wind_shader:
				has_wind_shader = true
		
		if has_wind_shader:
			# Keep wind shader but enable lighting in it
			if current_mat is ShaderMaterial:
				# Wind shaders already support lighting via fragment shader
				# Just ensure we're not using unshaded mode anymore
				print("[NatureIsland] Preserving wind animation for: " + group_name)
		else:
			# Find which asset type this group uses (for non-wind groups)
			var asset_type = asset_type_map.get(group_name, "")
			if asset_type == "":
				continue
			
			# Get first asset of that type (they all have same material)
			var assets = asset_library.get(asset_type, [])
			if assets.is_empty():
				continue
			
			var asset_data = assets[0]
			if asset_data.has("material_lit"):
				# Swap to pre-created lit material (instant, no shader compilation!)
				mmi.material_override = asset_data["material_lit"]
	
	print("[NatureIsland] Material swap complete - wind animation preserved!")

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

func _input(event):
	"""Handle keyboard input for early exit"""
	# Allow ESC to exit early
	if event.is_action_pressed("ui_cancel"):
		print("\n[NatureIsland] Cancelled by user")
		end_benchmark()

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

func profile_rendering_pipeline(delta: float):
	"""Comprehensive rendering pipeline profiling to identify bottlenecks"""
	
	# 1. VSync verification
	var vsync_mode = DisplayServer.window_get_vsync_mode()
	var vsync_names = ["DISABLED", "ENABLED", "ADAPTIVE", "MAILBOX"]
	
	# 2. RenderingServer statistics
	var render_info = {
		"objects_drawn": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		"primitives_drawn": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		"draw_calls": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		"texture_memory_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED) / 1024.0 / 1024.0,
		"video_memory_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1024.0 / 1024.0,
	}
	
	# 3. Frame timing breakdown
	var frame_ms = delta * 1000.0
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var render_time = frame_ms - process_time - physics_time
	
	# 4. GPU driver diagnostics
	var gpu_driver = RenderingServer.get_video_adapter_name()
	var gpu_vendor = RenderingServer.get_video_adapter_vendor()
	
	# Log every 60 frames for detailed diagnostics
	if Engine.get_process_frames() % 60 == 0:
		print("[PROFILE] VSync: %s | Draw Calls: %d | Objects: %d | Primitives: %d" % 
			[vsync_names[vsync_mode], render_info.draw_calls, render_info.objects_drawn, render_info.primitives_drawn])
		print("[PROFILE] VRAM: %.1fMB | Texture Mem: %.1fMB" % 
			[render_info.video_memory_mb, render_info.texture_memory_mb])
		print("[PROFILE] Frame: %.1fms (CPU: %.1fms, Physics: %.1fms, Render: %.1fms)" % 
			[frame_ms, process_time, physics_time, render_time])
		print("[PROFILE] GPU: %s (%s)" % [gpu_driver, gpu_vendor])

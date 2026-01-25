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

# Object counts (dense but optimized)
const TREE_COUNT = 100
const ROCK_COUNT = 40
const VEGETATION_COUNT = 80
const GROUND_DETAIL_COUNT = 60
const FLOWER_COUNT = 20

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
	print("[NatureIsland] Loading %d GLTF assets..." % 76)
	
	# Initialize performance monitor
	perf_monitor = PerformanceMonitor.new()
	perf_monitor.initialize()
	
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
	"""Load all 76 GLTF assets from nature-benchmark"""
	print("[NatureIsland] Loading asset library...")
	
	# Trees (16 assets)
	var tree_assets = [
		"island_tree_01_2k.gltf", "island_tree_02_2k.gltf", "island_tree_03_2k.gltf",
		"fir_tree_01_2k.gltf", "jacaranda_tree_2k.gltf",
		"quiver_tree_01_2k.gltf", "quiver_tree_02_2k.gltf",
		"tree_small_02_2k.gltf",
		"dead_tree_trunk_02_2k.gltf", "dead_tree_trunk_2k.gltf", "dead_quiver_trunk_2k.gltf",
		"tree_stump_01_2k.gltf", "tree_stump_02_2k.gltf",
		"pine_sapling_small_2k.gltf", "fir_sapling_2k.gltf", "fir_sapling_medium_2k.gltf"
	]
	
	# Rocks (13 assets)
	var rock_assets = [
		"boulder_01_2k.gltf",
		"coast_rocks_02_2k.gltf", "coast_rocks_03_2k.gltf",
		"rock_face_01_2k.gltf", "rock_face_02_2k.gltf", "rock_face_03_2k.gltf",
		"rock_moss_set_01_2k.gltf", "rock_moss_set_02_2k.gltf",
		"namaqualand_boulder_02_2k.gltf", "namaqualand_boulder_03_2k.gltf",
		"namaqualand_cliff_02_2k.gltf", "mountainside_2k.gltf",
		"moon_rock_01_2k.gltf", "stone_01_2k.gltf", "sand_rocks_small_01_2k.gltf"
	]
	
	# Vegetation (27 assets)
	var vegetation_assets = [
		"shrub_01_2k.gltf", "shrub_02_2k.gltf", "shrub_03_2k.gltf", "shrub_04_2k.gltf",
		"grass_medium_01_2k.gltf", "grass_medium_02_2k.gltf", "grass_bermuda_01_2k.gltf",
		"fern_02_2k.gltf",
		"flower_gazania_2k.gltf", "flower_empodium_2k.gltf", "flower_heliophila_2k.gltf",
		"flower_stinkkruid_2k.gltf", "flower_ursinia_2k.gltf", "dandelion_01_2k.gltf",
		"nettle_plant_2k.gltf", "periwinkle_plant_2k.gltf", "weed_plant_02_2k.gltf",
		"anthurium_botany_01_2k.gltf", "calathea_orbifolia_01_2k.gltf", "pachira_aquatica_01_2k.gltf",
		"celandine_01_2k.gltf",
		"cheiridopsis_succulent_2k.gltf", "crystalline_iceplant_2k.gltf",
		"othonna_cerarioides_2k.gltf",
		"searsia_burchellii_2k.gltf", "searsia_lucida_2k.gltf",
		"wild_rooibos_bush_2k.gltf"
	]
	
	# Ground (17 assets)
	var ground_assets = [
		"coast_sand_01_2k.gltf", "coast_sand_02_2k.gltf",
		"brown_mud_02_2k.gltf", "brown_mud_03_2k.gltf", "brown_mud_2k.gltf", "brown_mud_dry_2k.gltf",
		"park_dirt_2k.gltf",
		"forest_floor_2k.gltf", "forest_ground_04_2k.gltf",
		"forrest_ground_01_2k.gltf", "forrest_ground_03_2k.gltf",
		"forest_leaves_02_2k.gltf", "forest_leaves_03_2k.gltf", "leaves_forest_ground_2k.gltf",
		"bark_debris_01_2k.gltf", "dry_branches_medium_01_2k.gltf",
		"root_cluster_01_2k.gltf", "root_cluster_02_2k.gltf", "single_root_2k.gltf",
		"pine_roots_2k.gltf", "moss_01_2k.gltf", "rocky_trail_2k.gltf"
	]
	
	# Coastal (3 assets)
	var coastal_assets = [
		"coast_line_02_2k.gltf", "coast_land_rocks_04_2k.gltf", "coast_sand_rocks_02_2k.gltf"
	]
	
	# Load all assets
	for asset_name in tree_assets:
		var scene = load("res://art/nature-benchmark/" + asset_name)
		if scene:
			asset_library["trees"].append(scene)
	
	for asset_name in rock_assets:
		var scene = load("res://art/nature-benchmark/" + asset_name)
		if scene:
			asset_library["rocks"].append(scene)
	
	for asset_name in vegetation_assets:
		var scene = load("res://art/nature-benchmark/" + asset_name)
		if scene:
			asset_library["vegetation"].append(scene)
	
	for asset_name in ground_assets:
		var scene = load("res://art/nature-benchmark/" + asset_name)
		if scene:
			asset_library["ground"].append(scene)
	
	for asset_name in coastal_assets:
		var scene = load("res://art/nature-benchmark/" + asset_name)
		if scene:
			asset_library["coastal"].append(scene)
	
	print("[NatureIsland] Loaded assets: Trees=%d, Rocks=%d, Vegetation=%d, Ground=%d, Coastal=%d" %
		[asset_library["trees"].size(), asset_library["rocks"].size(), 
		asset_library["vegetation"].size(), asset_library["ground"].size(), 
		asset_library["coastal"].size()])

func extract_mesh_and_material_from_gltf(gltf_scene: PackedScene) -> Dictionary:
	"""Extract mesh and material from GLTF scene"""
	var instance = gltf_scene.instantiate()
	var mesh_instance = find_mesh_instance_recursive(instance)
	
	if not mesh_instance:
		instance.queue_free()
		return {"mesh": null, "material": null}
	
	var mesh = mesh_instance.mesh
	var material = null
	if mesh_instance.get_surface_override_material_count() > 0:
		material = mesh_instance.get_surface_override_material(0)
	elif mesh and mesh.get_surface_count() > 0:
		material = mesh.surface_get_material(0)
	
	instance.queue_free()
	return {"mesh": mesh, "material": material}

func find_mesh_instance_recursive(node: Node) -> MeshInstance3D:
	"""Recursively find MeshInstance3D in node tree"""
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = find_mesh_instance_recursive(child)
		if result:
			return result
	
	return null

func create_multimesh_from_assets(asset_list: Array, instance_count: int, zone: String) -> MultiMeshInstance3D:
	"""Create MultiMesh from list of assets"""
	if asset_list.is_empty() or instance_count == 0:
		return null
	
	var mmi = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	
	# Use first asset's mesh as the base
	var base_data = extract_mesh_and_material_from_gltf(asset_list[0])
	if not base_data["mesh"]:
		return null
	
	multimesh.mesh = base_data["mesh"]
	mmi.multimesh = multimesh
	
	# Apply material (make it unshaded for Phase 1)
	if base_data["material"] and base_data["material"] is StandardMaterial3D:
		var mat = base_data["material"].duplicate()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mmi.material_override = mat
	
	# Generate transforms based on zone
	var transforms = generate_transforms_for_zone(instance_count, zone)
	for i in range(instance_count):
		multimesh.set_instance_transform(i, transforms[i])
	
	add_child(mmi)
	return mmi

func generate_transforms_for_zone(count: int, zone: String) -> Array[Transform3D]:
	"""Generate transforms based on island zone"""
	var transforms: Array[Transform3D] = []
	var min_distance = 3.0  # Minimum distance between objects
	
	for i in range(count):
		var transform = Transform3D()
		var pos = Vector3.ZERO
		var attempts = 0
		
		while attempts < 50:
			if zone == "interior_forest":
				# Central dense forest
				pos = Vector3(
					randf_range(-15, 15),
					randf_range(0, 3),
					randf_range(-10, 10)
				)
			elif zone == "coastal":
				# Coastal ring
				var angle = randf() * TAU
				var radius = randf_range(18, 25)
				pos = Vector3(
					cos(angle) * radius,
					randf_range(0, 2),
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
					randf_range(0, 2),
					randf_range(-ISLAND_SIZE_Z/2, ISLAND_SIZE_Z/2)
				)
			
			# Check minimum distance
			var valid = true
			for existing_transform in transforms:
				if pos.distance_to(existing_transform.origin) < min_distance:
					valid = false
					break
			
			if valid:
				break
			attempts += 1
		
		# Random rotation and scale
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		var scale = randf_range(0.8, 1.3)
		transform = transform.scaled(Vector3(scale, scale, scale))
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
	
	# Create tree MultiMeshes (split into groups for variety)
	var large_trees = asset_library["trees"].slice(0, 5)  # island_tree, fir, jacaranda
	var small_trees = asset_library["trees"].slice(5, 11)  # quiver, small, dead
	var saplings = asset_library["trees"].slice(11, 16)  # stumps, saplings
	
	if not large_trees.is_empty():
		multimesh_groups["large_trees"] = create_multimesh_from_assets(large_trees, 60, "interior_forest")
		print("[NatureIsland] Created 60 large trees")
	
	if not small_trees.is_empty():
		multimesh_groups["small_trees"] = create_multimesh_from_assets(small_trees, 30, "coastal")
		print("[NatureIsland] Created 30 small trees")
	
	if not saplings.is_empty():
		multimesh_groups["saplings"] = create_multimesh_from_assets(saplings, 10, "clearing")
		print("[NatureIsland] Created 10 saplings")
	
	# Setup simple ocean (Phase 1: just color + basic UV scroll)
	setup_ocean_phase_1()
	
	update_metrics_overlay("Phase 1: Dense Forest + Ocean", "Trees: 100 | Draw Calls: ~4 | Target: 60 FPS")

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
	var boulders = asset_library["rocks"].slice(0, 5)
	var rock_faces = asset_library["rocks"].slice(5, 10)
	var small_rocks = asset_library["rocks"].slice(10, 15)
	
	if not boulders.is_empty():
		multimesh_groups["boulders"] = create_multimesh_from_assets(boulders, 15, "coastal")
		print("[NatureIsland] Created 15 boulders")
	
	if not rock_faces.is_empty():
		multimesh_groups["rock_faces"] = create_multimesh_from_assets(rock_faces, 10, "coastal")
		print("[NatureIsland] Created 10 rock faces")
	
	if not small_rocks.is_empty():
		multimesh_groups["small_rocks"] = create_multimesh_from_assets(small_rocks, 15, "general")
		print("[NatureIsland] Created 15 small rocks")
	
	# Animate ocean
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("wave_height", 0.3)
	
	update_metrics_overlay("Phase 2: + Rocks", "Objects: 140 | Draw Calls: ~7 | Target: 55 FPS")

func transition_to_phase_3():
	"""Phase 3: + Vegetation (70-105s) - Target 50 FPS"""
	current_phase = 3
	print("\n[NatureIsland] === PHASE 3: + Vegetation (70-105s) ===")
	
	# Add vegetation MultiMeshes
	var shrubs = asset_library["vegetation"].slice(0, 4)
	var grasses = asset_library["vegetation"].slice(4, 8)
	var flowers = asset_library["vegetation"].slice(8, 14)
	var plants = asset_library["vegetation"].slice(14, 20)
	var succulents = asset_library["vegetation"].slice(20, 27)
	
	if not shrubs.is_empty():
		multimesh_groups["shrubs"] = create_multimesh_from_assets(shrubs, 30, "clearing")
		print("[NatureIsland] Created 30 shrubs")
	
	if not grasses.is_empty():
		multimesh_groups["grasses"] = create_multimesh_from_assets(grasses, 25, "general")
		print("[NatureIsland] Created 25 grasses")
	
	if not flowers.is_empty():
		multimesh_groups["flowers"] = create_multimesh_from_assets(flowers, 15, "clearing")
		print("[NatureIsland] Created 15 flowers")
	
	if not plants.is_empty():
		multimesh_groups["plants"] = create_multimesh_from_assets(plants, 10, "interior_forest")
		print("[NatureIsland] Created 10 plants")
	
	# Add foam to water
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 3)
	
	update_metrics_overlay("Phase 3: + Vegetation", "Objects: 220 | Draw Calls: ~11 | Target: 50 FPS")

func transition_to_phase_4():
	"""Phase 4: + Ground Detail + Lighting (105-140s) - Target 45 FPS"""
	current_phase = 4
	print("\n[NatureIsland] === PHASE 4: + Ground Detail + Lighting (105-140s) ===")
	
	# Add ground detail MultiMeshes
	var forest_floor = asset_library["ground"].slice(0, 7)
	var roots = asset_library["ground"].slice(14, 18)
	var moss = asset_library["ground"].slice(18, 22)
	var coastal_ground = asset_library["coastal"]
	
	if not forest_floor.is_empty():
		multimesh_groups["forest_floor"] = create_multimesh_from_assets(forest_floor, 30, "interior_forest")
		print("[NatureIsland] Created 30 forest floor patches")
	
	if not roots.is_empty():
		multimesh_groups["roots"] = create_multimesh_from_assets(roots, 15, "interior_forest")
		print("[NatureIsland] Created 15 root clusters")
	
	if not moss.is_empty():
		multimesh_groups["moss"] = create_multimesh_from_assets(moss, 10, "general")
		print("[NatureIsland] Created 10 moss patches")
	
	if not coastal_ground.is_empty():
		multimesh_groups["coastal_ground"] = create_multimesh_from_assets(coastal_ground, 5, "coastal")
		print("[NatureIsland] Created 5 coastal ground elements")
	
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
	
	update_metrics_overlay("Phase 4: + Ground + Lighting", "Objects: 280 | Draw Calls: ~15 | Target: 45 FPS")

func transition_to_phase_5():
	"""Phase 5: + Shadows + Glow (140-176s) - Target 35-40 FPS"""
	current_phase = 5
	print("\n[NatureIsland] === PHASE 5: + Shadows + Glow (140-176s) ===")
	
	# Enable shadows
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 60.0
	
	# Enable glow
	if env.environment:
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 0.5
		env.environment.glow_strength = 0.8
		env.environment.glow_bloom = 0.15
	
	# Full water shader
	var mat = ocean.get_surface_override_material(0) if ocean else null
	if mat and mat is ShaderMaterial:
		mat.set_shader_parameter("phase", 5)
		mat.set_shader_parameter("wave_height", 0.8)
	
	update_metrics_overlay("Phase 5: + Shadows + Glow", "Objects: 280+ | Draw Calls: ~15 | Target: 35-40 FPS")

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
	
	# Update performance monitor
	perf_monitor.update(get_process_delta_time())
	
	# Get current metrics
	last_fps = perf_monitor.get_fps()
	last_frame_time = perf_monitor.get_frame_time()
	last_cpu = perf_monitor.get_cpu_usage()
	last_temp = perf_monitor.get_temperature()
	last_gpu = perf_monitor.get_gpu_usage()
	
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

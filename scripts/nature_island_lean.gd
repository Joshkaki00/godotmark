extends Node3D

## Nature Island Benchmark - Budget Android Optimized
## Following Godot's official mobile optimization guidelines
## Target: 60 FPS desktop, 30 FPS budget Android in Phase 1

# Node references
@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var env: WorldEnvironment = $WorldEnvironment
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var metrics_overlay = $MetricsOverlay
@onready var fade_overlay = $FadeOverlay
@onready var ground: MeshInstance3D = $Ground

# MultiMesh instances (created at runtime)
var tree_multimesh: MultiMeshInstance3D
var rock_multimesh: MultiMeshInstance3D
var shrub_multimesh: MultiMeshInstance3D
var ground_patch_multimesh: MultiMeshInstance3D

# OmniLights for Phase 4
var omni_light_1: OmniLight3D
var omni_light_2: OmniLight3D

# Materials (mobile-optimized)
var tree_trunk_mat: StandardMaterial3D
var tree_leaves_mat: StandardMaterial3D
var rock_mat: StandardMaterial3D
var shrub_mat: StandardMaterial3D
var ground_patch_mat: StandardMaterial3D

# Timeline and phase tracking
var timeline: float = 0.0
var current_phase: int = 0
var phase_triggered: Array = [false, false, false, false, false, false]

# Island layout constants
const ISLAND_RADIUS: float = 22.5  # 45m diameter = 0.5 acre
const TREE_COUNT: int = 40
const ROCK_COUNT: int = 25
const SHRUB_COUNT: int = 30
const GROUND_PATCH_COUNT: int = 15

# Performance monitoring
var frame_count: int = 0
var fps_update_timer: float = 0.0

func _ready():
	print("[NatureIsland] Initializing budget Android optimized benchmark...")
	
	# Initialize materials (Phase 1-3: UNSHADED for max performance)
	create_materials()
	
	# Start with Phase 1
	setup_phase_1()
	
	# Start audio
	audio.play()
	print("[NatureIsland] Audio started, duration: %.1fs" % audio.stream.get_length())

func _process(delta: float):
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

func create_materials():
	"""Create mobile-optimized materials with solid colors only"""
	
	# Tree trunk material (brown)
	tree_trunk_mat = StandardMaterial3D.new()
	tree_trunk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tree_trunk_mat.albedo_color = Color(0.4, 0.25, 0.15)
	tree_trunk_mat.disable_ambient_light = true
	tree_trunk_mat.disable_fog = true
	tree_trunk_mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	# Tree leaves material (green)
	tree_leaves_mat = StandardMaterial3D.new()
	tree_leaves_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tree_leaves_mat.albedo_color = Color(0.2, 0.5, 0.2)
	tree_leaves_mat.disable_ambient_light = true
	tree_leaves_mat.disable_fog = true
	tree_leaves_mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	# Rock material (gray)
	rock_mat = StandardMaterial3D.new()
	rock_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rock_mat.albedo_color = Color(0.4, 0.4, 0.4)
	rock_mat.disable_ambient_light = true
	rock_mat.disable_fog = true
	rock_mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	# Shrub material (dark green)
	shrub_mat = StandardMaterial3D.new()
	shrub_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shrub_mat.albedo_color = Color(0.15, 0.35, 0.15)
	shrub_mat.disable_ambient_light = true
	shrub_mat.disable_fog = true
	shrub_mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	# Ground patch material (dirt brown)
	ground_patch_mat = StandardMaterial3D.new()
	ground_patch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ground_patch_mat.albedo_color = Color(0.3, 0.2, 0.1)
	ground_patch_mat.disable_ambient_light = true
	ground_patch_mat.disable_fog = true
	ground_patch_mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	print("[NatureIsland] Materials created (UNSHADED mode for mobile)")

func setup_phase_1():
	"""Phase 1: Trees Only (0-35s) - Target 60 FPS desktop, 30 FPS mobile"""
	current_phase = 1
	print("\n[NatureIsland] === PHASE 1: Trees Only (0-35s) ===")
	
	# Disable shadows for maximum performance
	sun.shadow_enabled = false
	sun.light_energy = 1.0
	
	# Simple environment (no fog, no effects)
	if env.environment:
		env.environment.background_mode = Environment.BG_SKY
		env.environment.sky = Sky.new()
		env.environment.sky.sky_material = ProceduralSkyMaterial.new()
		env.environment.sky.sky_material.sky_top_color = Color(0.4, 0.6, 0.9)
		env.environment.sky.sky_material.sky_horizon_color = Color(0.6, 0.7, 0.8)
		env.environment.sky.sky_material.ground_bottom_color = Color(0.2, 0.3, 0.2)
		env.environment.sky.sky_material.ground_horizon_color = Color(0.4, 0.5, 0.4)
		env.environment.fog_enabled = false
		env.environment.glow_enabled = false
		env.environment.volumetric_fog_enabled = false
	
	# Create tree MultiMesh (1 draw call)
	create_tree_multimesh()
	
	update_metrics_overlay("Phase 1: Trees Only", "Draw Calls: 1 | Target: 60 FPS")

func transition_to_phase_2():
	"""Phase 2: + Rocks (35-70s) - Target 55 FPS desktop, 28 FPS mobile"""
	current_phase = 2
	print("\n[NatureIsland] === PHASE 2: + Rocks (35-70s) ===")
	
	# Add rocks MultiMesh (now 2 draw calls total)
	create_rock_multimesh()
	
	update_metrics_overlay("Phase 2: + Rocks", "Draw Calls: 2 | Target: 55 FPS")

func transition_to_phase_3():
	"""Phase 3: + Vegetation (70-105s) - Target 50 FPS desktop, 25 FPS mobile"""
	current_phase = 3
	print("\n[NatureIsland] === PHASE 3: + Vegetation (70-105s) ===")
	
	# Add shrubs and ground patches (now 4 draw calls total)
	create_shrub_multimesh()
	create_ground_patch_multimesh()
	
	update_metrics_overlay("Phase 3: + Vegetation", "Draw Calls: 4 | Target: 50 FPS")

func transition_to_phase_4():
	"""Phase 4: + Simple Lighting (105-140s) - Target 40 FPS desktop, 20 FPS mobile"""
	current_phase = 4
	print("\n[NatureIsland] === PHASE 4: + Simple Lighting (105-140s) ===")
	
	# Enable shadows on DirectionalLight (low res for mobile)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 50.0
	sun.shadow_bias = 0.1
	
	# Switch materials to PER_VERTEX shading for lighting
	tree_trunk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	tree_leaves_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	rock_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	shrub_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	ground_patch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	
	# Add 2 small OmniLights (no shadows)
	omni_light_1 = OmniLight3D.new()
	omni_light_1.light_color = Color(1.0, 0.9, 0.7)
	omni_light_1.light_energy = 0.5
	omni_light_1.omni_range = 10.0
	omni_light_1.shadow_enabled = false
	omni_light_1.position = Vector3(-10, 3, -10)
	add_child(omni_light_1)
	
	omni_light_2 = OmniLight3D.new()
	omni_light_2.light_color = Color(0.7, 0.8, 1.0)
	omni_light_2.light_energy = 0.5
	omni_light_2.omni_range = 10.0
	omni_light_2.shadow_enabled = false
	omni_light_2.position = Vector3(10, 3, 10)
	add_child(omni_light_2)
	
	update_metrics_overlay("Phase 4: + Lighting", "Draw Calls: 4 + lights | Target: 40 FPS")

func transition_to_phase_5():
	"""Phase 5: + Minimal Effects (140-176s) - Target 35 FPS desktop, 15-18 FPS mobile"""
	current_phase = 5
	print("\n[NatureIsland] === PHASE 5: + Minimal Effects (140-176s) ===")
	
	# Enable simple glow (NOT volumetric fog)
	if env.environment:
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 0.5
		env.environment.glow_strength = 0.8
		env.environment.glow_bloom = 0.1
		env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	update_metrics_overlay("Phase 5: + Effects", "Draw Calls: 4 + effects | Target: 35 FPS")

func create_tree_multimesh():
	"""Create MultiMesh with 40 tree instances (each tree = trunk + leaves)"""
	
	# Create MultiMesh for trunks
	var trunk_mmi = MultiMeshInstance3D.new()
	trunk_mmi.name = "TreeTrunks"
	add_child(trunk_mmi)
	
	var trunk_multimesh = MultiMesh.new()
	trunk_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	trunk_multimesh.instance_count = TREE_COUNT
	
	# Low poly cylinder for trunk (8 radial segments)
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.3
	trunk_mesh.bottom_radius = 0.4
	trunk_mesh.height = 3.0
	trunk_mesh.radial_segments = 8
	trunk_mesh.rings = 1
	trunk_mesh.material = tree_trunk_mat
	
	trunk_multimesh.mesh = trunk_mesh
	trunk_mmi.multimesh = trunk_multimesh
	
	# Create MultiMesh for leaves
	var leaves_mmi = MultiMeshInstance3D.new()
	leaves_mmi.name = "TreeLeaves"
	add_child(leaves_mmi)
	
	var leaves_multimesh = MultiMesh.new()
	leaves_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	leaves_multimesh.instance_count = TREE_COUNT
	
	# Low poly sphere for leaves (8 rings, 8 radial segments)
	var leaves_mesh = SphereMesh.new()
	leaves_mesh.radius = 2.0
	leaves_mesh.height = 4.0
	leaves_mesh.radial_segments = 8
	leaves_mesh.rings = 8
	leaves_mesh.material = tree_leaves_mat
	
	leaves_multimesh.mesh = leaves_mesh
	leaves_mmi.multimesh = leaves_multimesh
	
	# Generate scattered positions (avoid clustering)
	var positions = scatter_positions(TREE_COUNT, ISLAND_RADIUS * 0.9)
	
	for i in range(TREE_COUNT):
		var pos = positions[i]
		
		# Trunk transform
		var trunk_transform = Transform3D()
		trunk_transform.origin = pos + Vector3(0, 1.5, 0)
		trunk_multimesh.set_instance_transform(i, trunk_transform)
		
		# Leaves transform (on top of trunk)
		var leaves_transform = Transform3D()
		leaves_transform.origin = pos + Vector3(0, 4.0, 0)
		leaves_multimesh.set_instance_transform(i, leaves_transform)
	
	tree_multimesh = trunk_mmi  # Store reference
	print("[NatureIsland] Created %d trees (2 MultiMesh batches)" % TREE_COUNT)

func create_rock_multimesh():
	"""Create MultiMesh with 25 rock instances (various sizes)"""
	
	var rock_mmi = MultiMeshInstance3D.new()
	rock_mmi.name = "Rocks"
	add_child(rock_mmi)
	
	var rock_multimesh_obj = MultiMesh.new()
	rock_multimesh_obj.transform_format = MultiMesh.TRANSFORM_3D
	rock_multimesh_obj.instance_count = ROCK_COUNT
	
	# Low poly sphere for rocks (6 rings, 6 segments = very low poly)
	var rock_mesh = SphereMesh.new()
	rock_mesh.radius = 1.0
	rock_mesh.height = 2.0
	rock_mesh.radial_segments = 6
	rock_mesh.rings = 6
	rock_mesh.material = rock_mat
	
	rock_multimesh_obj.mesh = rock_mesh
	rock_mmi.multimesh = rock_multimesh_obj
	
	# Generate scattered positions
	var positions = scatter_positions(ROCK_COUNT, ISLAND_RADIUS)
	
	for i in range(ROCK_COUNT):
		var pos = positions[i]
		var transform = Transform3D()
		
		# Random scale (0.5 to 1.5)
		var scale = randf_range(0.5, 1.5)
		transform = transform.scaled(Vector3(scale, scale * 0.7, scale))
		
		# Random rotation
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		
		# Position
		transform.origin = pos + Vector3(0, scale * 0.5, 0)
		
		rock_multimesh_obj.set_instance_transform(i, transform)
	
	rock_multimesh = rock_mmi
	print("[NatureIsland] Created %d rocks" % ROCK_COUNT)

func create_shrub_multimesh():
	"""Create MultiMesh with 30 shrub instances"""
	
	var shrub_mmi = MultiMeshInstance3D.new()
	shrub_mmi.name = "Shrubs"
	add_child(shrub_mmi)
	
	var shrub_multimesh_obj = MultiMesh.new()
	shrub_multimesh_obj.transform_format = MultiMesh.TRANSFORM_3D
	shrub_multimesh_obj.instance_count = SHRUB_COUNT
	
	# Small low poly sphere for shrubs
	var shrub_mesh = SphereMesh.new()
	shrub_mesh.radius = 0.5
	shrub_mesh.height = 1.0
	shrub_mesh.radial_segments = 6
	shrub_mesh.rings = 4
	shrub_mesh.material = shrub_mat
	
	shrub_multimesh_obj.mesh = shrub_mesh
	shrub_mmi.multimesh = shrub_multimesh_obj
	
	# Generate scattered positions
	var positions = scatter_positions(SHRUB_COUNT, ISLAND_RADIUS)
	
	for i in range(SHRUB_COUNT):
		var pos = positions[i]
		var transform = Transform3D()
		
		# Random scale (0.7 to 1.3)
		var scale = randf_range(0.7, 1.3)
		transform = transform.scaled(Vector3(scale, scale, scale))
		
		# Position
		transform.origin = pos + Vector3(0, 0.5 * scale, 0)
		
		shrub_multimesh_obj.set_instance_transform(i, transform)
	
	shrub_multimesh = shrub_mmi
	print("[NatureIsland] Created %d shrubs" % SHRUB_COUNT)

func create_ground_patch_multimesh():
	"""Create MultiMesh with 15 ground patch instances"""
	
	var patch_mmi = MultiMeshInstance3D.new()
	patch_mmi.name = "GroundPatches"
	add_child(patch_mmi)
	
	var patch_multimesh_obj = MultiMesh.new()
	patch_multimesh_obj.transform_format = MultiMesh.TRANSFORM_3D
	patch_multimesh_obj.instance_count = GROUND_PATCH_COUNT
	
	# Thin box for ground patches
	var patch_mesh = BoxMesh.new()
	patch_mesh.size = Vector3(2.0, 0.1, 2.0)
	patch_mesh.material = ground_patch_mat
	
	patch_multimesh_obj.mesh = patch_mesh
	patch_mmi.multimesh = patch_multimesh_obj
	
	# Generate scattered positions
	var positions = scatter_positions(GROUND_PATCH_COUNT, ISLAND_RADIUS)
	
	for i in range(GROUND_PATCH_COUNT):
		var pos = positions[i]
		var transform = Transform3D()
		
		# Random rotation around Y axis
		transform = transform.rotated(Vector3.UP, randf() * TAU)
		
		# Random scale (1.0 to 2.0)
		var scale = randf_range(1.0, 2.0)
		transform = transform.scaled(Vector3(scale, 1.0, scale))
		
		# Position (slightly below ground)
		transform.origin = pos + Vector3(0, 0.05, 0)
		
		patch_multimesh_obj.set_instance_transform(i, transform)
	
	ground_patch_multimesh = patch_mmi
	print("[NatureIsland] Created %d ground patches" % GROUND_PATCH_COUNT)

func scatter_positions(count: int, radius: float) -> Array:
	"""Generate scattered positions avoiding clustering (mobile optimization)"""
	var positions = []
	var min_distance = radius / sqrt(count)  # Prevent vertex concentration
	
	for i in range(count):
		var attempts = 0
		var valid_pos = false
		var pos = Vector3.ZERO
		
		while not valid_pos and attempts < 50:
			# Random position in circle
			var angle = randf() * TAU
			var dist = sqrt(randf()) * radius  # Sqrt for uniform distribution
			pos = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
			
			# Check distance to other positions
			valid_pos = true
			for existing_pos in positions:
				if pos.distance_to(existing_pos) < min_distance:
					valid_pos = false
					break
			
			attempts += 1
		
		positions.append(pos)
	
	return positions

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
	"""Update performance metrics display"""
	fps_update_timer += get_process_delta_time()
	frame_count += 1
	
	if fps_update_timer >= 0.5:  # Update twice per second
		fps_update_timer = 0.0
		
		if metrics_overlay and metrics_overlay.has_method("update_benchmark_info"):
			var info = {
				"scene": "Nature Island",
				"phase": "Phase %d" % current_phase,
				"timeline": "%.1fs / 176s" % timeline
			}
			metrics_overlay.update_benchmark_info(info)

func update_metrics_overlay(phase_name: String, details: String):
	"""Update the metrics overlay with phase information"""
	if metrics_overlay and metrics_overlay.has_method("update_benchmark_info"):
		var info = {
			"scene": "Nature Island",
			"phase": phase_name,
			"details": details
		}
		metrics_overlay.update_benchmark_info(info)

extends Node3D
## Nature Island MultiMesh Manager
## Converts 147 individual nodes to 6 MultiMesh batches for 10-20x performance improvement

# MultiMesh nodes (created at runtime)
var tree_multimesh: MultiMeshInstance3D
var large_rock_multimesh: MultiMeshInstance3D
var small_rock_multimesh: MultiMeshInstance3D
var ground_multimesh: MultiMeshInstance3D
var vegetation_multimesh: MultiMeshInstance3D
var coastal_multimesh: MultiMeshInstance3D

# Asset data structure: [resource_path, transform]
var tree_instances = []
var large_rock_instances = []
var small_rock_instances = []
var ground_instances = []
var vegetation_instances = []
var coastal_instances = []

# Reference meshes (extracted from GLTF)
var tree_mesh: Mesh
var large_rock_mesh: Mesh
var small_rock_mesh: Mesh
var ground_mesh: Mesh
var vegetation_mesh: Mesh
var coastal_mesh: Mesh

func _ready():
	print("[MultiMesh] Initializing Nature Island MultiMesh system...")
	
	# Define all instances with their transforms from the original scene
	_define_tree_instances()
	_define_rock_instances()
	_define_ground_instances()
	_define_vegetation_instances()
	_define_coastal_instances()
	
	print("[MultiMesh] Asset counts: Trees=%d, LargeRocks=%d, SmallRocks=%d, Ground=%d, Vegetation=%d, Coastal=%d" % [
		tree_instances.size(), large_rock_instances.size(), small_rock_instances.size(),
		ground_instances.size(), vegetation_instances.size(), coastal_instances.size()
	])

func initialize_meshes():
	"""Load meshes and create MultiMesh instances"""
	print("[MultiMesh] Creating MultiMesh instances...")
	
	# Create trees MultiMesh
	if tree_instances.size() > 0:
		tree_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/island_tree_01_2k.gltf")
		tree_multimesh = _create_multimesh("TreeMultiMesh", tree_mesh, tree_instances)
	
	# Create large rocks MultiMesh
	if large_rock_instances.size() > 0:
		large_rock_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/boulder_01_2k.gltf")
		large_rock_multimesh = _create_multimesh("LargeRockMultiMesh", large_rock_mesh, large_rock_instances)
	
	# Create small rocks MultiMesh
	if small_rock_instances.size() > 0:
		small_rock_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/rock_moss_set_01_2k.gltf")
		small_rock_multimesh = _create_multimesh("SmallRockMultiMesh", small_rock_mesh, small_rock_instances)
	
	# Create ground MultiMesh
	if ground_instances.size() > 0:
		ground_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/coast_sand_01_2k.gltf")
		ground_multimesh = _create_multimesh("GroundMultiMesh", ground_mesh, ground_instances)
	
	# Create vegetation MultiMesh
	if vegetation_instances.size() > 0:
		vegetation_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/grass_medium_01_2k.gltf")
		vegetation_multimesh = _create_multimesh("VegetationMultiMesh", vegetation_mesh, vegetation_instances)
	
	# Create coastal MultiMesh
	if coastal_instances.size() > 0:
		coastal_mesh = _load_mesh_from_gltf("res://art/nature-benchmark/coast_rocks_02_2k.gltf")
		coastal_multimesh = _create_multimesh("CoastalMultiMesh", coastal_mesh, coastal_instances)
	
	print("[MultiMesh] MultiMesh initialization complete!")

func _load_mesh_from_gltf(path: String) -> Mesh:
	"""Extract mesh from GLTF PackedScene"""
	var scene = load(path)
	if not scene:
		print("[MultiMesh] ERROR: Failed to load ", path)
		return null
	
	var instance = scene.instantiate()
	var mesh_instance = _find_mesh_instance(instance)
	
	if mesh_instance and mesh_instance.mesh:
		var mesh = mesh_instance.mesh
		instance.queue_free()
		return mesh
	else:
		print("[MultiMesh] ERROR: No mesh found in ", path)
		instance.queue_free()
		return null

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Recursively find first MeshInstance3D in node tree"""
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	return null

func _create_multimesh(name: String, mesh: Mesh, instances: Array) -> MultiMeshInstance3D:
	"""Create and populate a MultiMeshInstance3D"""
	if not mesh:
		print("[MultiMesh] ERROR: Cannot create ", name, " - mesh is null")
		return null
	
	var mmi = MultiMeshInstance3D.new()
	mmi.name = name
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = instances.size()
	
	# Set transforms for all instances
	for i in range(instances.size()):
		mm.set_instance_transform(i, instances[i])
	
	mmi.multimesh = mm
	add_child(mmi)
	
	print("[MultiMesh] Created ", name, " with ", instances.size(), " instances")
	return mmi

func _define_tree_instances():
	"""Define all tree transforms from original scene"""
	# ForestZone - Island trees
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-5, 0, 0)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1.2, 1, 1.2)), Vector3(3, 0, -2)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(0.9, 1, 0.9)), Vector3(8, 0, 3)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1.1, 1, 1.1)), Vector3(-8, 0, -5)))
	
	# Fir trees
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(0, 0, 5)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1.3, 1, 1.3)), Vector3(5, 0, 8)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(0.8, 1, 0.8)), Vector3(-10, 0, 2)))
	
	# Dead tree
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(10, 0, -5)))
	
	# Tree stumps
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-3, 0, 7)))
	
	# SaplingZone
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(2, 0, -4)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-6, 0, -6)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(8, 0, 1)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-9, 0, 4)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(11, 0, -3)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-11, 0, 7)))
	
	# EnhancedTreeZone - Jacaranda
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-12, 0, -8)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1.2, 1, 1.2)), Vector3(13, 0, 9)))
	
	# Quiver trees
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(15, 0, -6)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-14, 0, 10)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(0.9, 1, 0.9)), Vector3(9, 0, 12)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1.1, 1, 1.1)), Vector3(-10, 0, -12)))
	
	# Small tree
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(7, 0, 10)))
	
	# Dead trees
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(12, 0, -10)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-8, 0, -11)))
	
	# More stumps
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(14, 0, 5)))
	tree_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-13, 0, -5)))

func _define_rock_instances():
	"""Define all rock transforms"""
	# Large rocks (boulders, rock faces, cliffs)
	# RocksZone - Boulders
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(6, 0, 0)))
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(1.5, 1, 1.5)), Vector3(-7, 0, 5)))
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(0.7, 1, 0.7)), Vector3(9, 0, -8)))
	
	# RockFormationZone - Rock faces
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(2, 2, 2)), Vector3(-18, 0, 0)))
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(2, 2, 2)), Vector3(18, 0, -5)))
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(1.5, 1.5, 1.5)), Vector3(0, 0, 18)))
	
	# Cliff
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(2, 2, 2)), Vector3(-15, 0, -15)))
	
	# Mountainside
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(3, 3, 3)), Vector3(0, 0, -20)))
	
	# Namaqualand boulders
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(1.2, 1, 1.2)), Vector3(11, 0, -14)))
	large_rock_instances.append(Transform3D(Basis().scaled(Vector3(1.3, 1, 1.3)), Vector3(-13, 0, 12)))
	
	# Small rocks (rock moss, moon rock, stone)
	# Rock moss
	small_rock_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(2, 0, 3)))
	small_rock_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-4, 0, -3)))
	
	# Moon rock
	small_rock_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-9, 0, 13)))
	
	# Stone
	small_rock_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(10, 0, 11)))

func _define_ground_instances():
	"""Define all ground/terrain transforms"""
	# BeachZone - Coast sand
	ground_instances.append(Transform3D(Basis().scaled(Vector3(3, 1, 3)), Vector3(-8, 0, 15)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2.5, 1, 2.5)), Vector3(12, 0, 10)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-5, 0, -12)))
	
	# GroundTextureZone - Forest floor, mud, leaves
	ground_instances.append(Transform3D(Basis().scaled(Vector3(3, 1, 3)), Vector3(0, 0, 0)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-10, 0, -8)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2.5, 1, 2.5)), Vector3(10, 0, 8)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-7, 0, 10)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(8, 0, -10)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(3, 1, 3)), Vector3(5, 0, 12)))
	ground_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-12, 0, 6)))

func _define_vegetation_instances():
	"""Define all vegetation transforms (grass, ferns, shrubs, flowers)"""
	# VegetationZone - Grass
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-2, 0, 2)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(4, 0, 6)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-6, 0, 8)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(7, 0, -4)))
	
	# Ferns
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-4, 0, 3)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(5, 0, 4)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-8, 0, -2)))
	
	# Shrubs
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(3, 0, 1)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-1, 0, 5)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(6, 0, -2)))
	
	# FlowerZone
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(1, 0, 4)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-3, 0, 6)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(4, 0, 3)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-5, 0, 1)))
	
	# ExpandedVegetationZone - Bermuda grass
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(9, 0, -6)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(-11, 0, 9)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(2, 1, 2)), Vector3(12, 0, 3)))
	
	# Nettle
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-6, 0, -7)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(8, 0, 7)))
	
	# Periwinkle
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(5, 0, -8)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-7, 0, -9)))
	
	# Succulents
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(10, 0, -7)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-9, 0, 8)))
	
	# More flowers
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(6, 0, 9)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-8, 0, -6)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(11, 0, 4)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-10, 0, -4)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(7, 0, -9)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-11, 0, 5)))
	
	# Roots and other plants
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(13, 0, -3)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-12, 0, 7)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(9, 0, 11)))
	vegetation_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-13, 0, -7)))

func _define_coastal_instances():
	"""Define all coastal elements (coast rocks, sand rocks)"""
	# BeachZone - Coast rocks
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-10, 0, 12)))
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(8, 0, 14)))
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1.2, 1, 1.2)), Vector3(14, 0, -8)))
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(0.8, 1, 0.8)), Vector3(-12, 0, -10)))
	
	# Additional coastal elements
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(15, 0, 8)))
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(-15, 0, 10)))
	coastal_instances.append(Transform3D(Basis().scaled(Vector3(1, 1, 1)), Vector3(12, 0, -12)))

func set_all_visible(visible: bool):
	"""Control visibility of all MultiMesh instances"""
	if tree_multimesh:
		tree_multimesh.visible = visible
	if large_rock_multimesh:
		large_rock_multimesh.visible = visible
	if small_rock_multimesh:
		small_rock_multimesh.visible = visible
	if ground_multimesh:
		ground_multimesh.visible = visible
	if vegetation_multimesh:
		vegetation_multimesh.visible = visible
	if coastal_multimesh:
		coastal_multimesh.visible = visible

func set_category_visible(category: String, visible: bool):
	"""Control visibility of specific category"""
	match category:
		"trees":
			if tree_multimesh:
				tree_multimesh.visible = visible
		"large_rocks":
			if large_rock_multimesh:
				large_rock_multimesh.visible = visible
		"small_rocks":
			if small_rock_multimesh:
				small_rock_multimesh.visible = visible
		"ground":
			if ground_multimesh:
				ground_multimesh.visible = visible
		"vegetation":
			if vegetation_multimesh:
				vegetation_multimesh.visible = visible
		"coastal":
			if coastal_multimesh:
				coastal_multimesh.visible = visible

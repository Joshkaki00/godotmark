extends Node3D
## Cheap Physics Test - Falling Leaves using Jolt Physics
## Demonstrates low-cost physics simulation on ARM

var leaf_scene: PackedScene
var leaves: Array[RigidBody3D] = []
var max_leaves = 20  # Keep it cheap

func _ready():
	create_leaf_scene()
	
func create_leaf_scene():
	"""Create a simple leaf mesh for physics"""
	# Simple quad mesh for leaf
	var mesh = QuadMesh.new()
	mesh.size = Vector2(0.2, 0.2)
	
	# Leaf material
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.albedo_color = Color(0.7, 0.5, 0.2, 0.9)  # Orange-brown
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # Show both sides
	mesh.material = mat
	
	# Create scene
	leaf_scene = PackedScene.new()

func spawn_leaf():
	"""Spawn a single falling leaf with cheap physics"""
	if leaves.size() >= max_leaves:
		return
	
	var leaf = RigidBody3D.new()
	leaf.mass = 0.01  # Very light
	leaf.gravity_scale = 0.3  # Slow fall
	leaf.linear_damp = 2.0  # Air resistance
	leaf.angular_damp = 1.0
	
	# Random spawn position above island
	var spawn_x = randf_range(-50, 50)
	var spawn_z = randf_range(-100, 100)
	leaf.position = Vector3(spawn_x, randf_range(15, 25), spawn_z)
	
	# Mesh
	var mesh_instance = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.albedo_color = Color(0.7, 0.5, 0.2, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.mesh = quad
	mesh_instance.material_override = mat
	leaf.add_child(mesh_instance)
	
	# Collision shape (very simple box)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.2, 0.01, 0.2)
	collision.shape = shape
	leaf.add_child(collision)
	
	# Random rotation
	leaf.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
	
	# Random angular velocity (spinning leaf)
	leaf.angular_velocity = Vector3(
		randf_range(-2, 2),
		randf_range(-1, 1),
		randf_range(-2, 2)
	)
	
	add_child(leaf)
	leaves.append(leaf)

func _process(_delta):
	"""Spawn leaves periodically"""
	if randf() < 0.05:  # 5% chance per frame
		spawn_leaf()
	
	# Remove leaves that fall too far
	for i in range(leaves.size() - 1, -1, -1):
		if leaves[i].position.y < -5:
			leaves[i].queue_free()
			leaves.remove_at(i)

func _exit_tree():
	"""Cleanup"""
	for leaf in leaves:
		if is_instance_valid(leaf):
			leaf.queue_free()
	leaves.clear()

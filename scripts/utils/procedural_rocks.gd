extends Node3D
## Simple procedural rock generator for Nature Island benchmark
## Creates low-poly rocks from deformed sphere meshes

static func create_rock_mesh(seed_value: int = 0) -> ArrayMesh:
	"""Generate a simple low-poly rock mesh from a deformed icosphere"""
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Start with a low-poly sphere (subdivisions = 1 for ~80 triangles)
	var sphere = SphereMesh.new()
	sphere.radial_segments = 8
	sphere.rings = 4
	sphere.radius = 1.0
	sphere.height = 2.0
	
	# Get mesh data
	var arrays = sphere.get_mesh_arrays()
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	
	# Deform vertices to make it look rocky
	for i in range(vertices.size()):
		var vert = vertices[i]
		
		# Add random displacement (make it lumpy)
		var displacement = rng.randf_range(0.7, 1.3)
		vert *= displacement
		
		# Squash it a bit (rocks aren't perfect spheres)
		vert.y *= rng.randf_range(0.5, 0.8)
		
		# Add noise-like deformation
		vert.x += rng.randf_range(-0.2, 0.2)
		vert.z += rng.randf_range(-0.2, 0.2)
		
		vertices[i] = vert
	
	# Recalculate normals for the deformed mesh
	normals = []
	var indices = arrays[Mesh.ARRAY_INDEX]
	normals.resize(vertices.size())
	normals.fill(Vector3.ZERO)
	
	# Calculate face normals and accumulate
	for i in range(0, indices.size(), 3):
		var i0 = indices[i]
		var i1 = indices[i + 1]
		var i2 = indices[i + 2]
		
		var v0 = vertices[i0]
		var v1 = vertices[i1]
		var v2 = vertices[i2]
		
		var edge1 = v1 - v0
		var edge2 = v2 - v0
		var face_normal = edge1.cross(edge2).normalized()
		
		normals[i0] += face_normal
		normals[i1] += face_normal
		normals[i2] += face_normal
	
	# Normalize accumulated normals
	for i in range(normals.size()):
		normals[i] = normals[i].normalized()
	
	# Create new mesh with deformed vertices
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh

static func create_rock_material(base_color: Color = Color(0.5, 0.5, 0.5)) -> StandardMaterial3D:
	"""Create a simple rock material"""
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.albedo_color = base_color
	mat.roughness = 0.9
	mat.metallic = 0.0
	return mat

static func create_rock_variations(count: int = 3) -> Array:
	"""Create multiple rock mesh variations"""
	var rocks = []
	for i in range(count):
		var rock_data = {
			"mesh": create_rock_mesh(i * 1000),
			"material_lit": create_rock_material(Color(
				randf_range(0.4, 0.6),
				randf_range(0.4, 0.5),
				randf_range(0.35, 0.45)
			))
		}
		rocks.append(rock_data)
	return rocks

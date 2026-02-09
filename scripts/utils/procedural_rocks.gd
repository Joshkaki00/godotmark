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
	
	# Get mesh data as surface tool (easier to work with)
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(sphere, 0)
	
	# Generate mesh data
	var array_mesh = surface_tool.commit()
	var arrays = array_mesh.surface_get_arrays(0)
	
	# Get vertices as PackedVector3Array
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var vertex_array: Array = []
	
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
		
		vertex_array.append(vert)
	
	# Rebuild mesh with SurfaceTool (handles normals automatically)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	
	# Add vertices with UVs
	for i in range(0, indices.size(), 3):
		var i0 = indices[i]
		var i1 = indices[i + 1]
		var i2 = indices[i + 2]
		
		# Calculate face normal
		var v0 = vertex_array[i0]
		var v1 = vertex_array[i1]
		var v2 = vertex_array[i2]
		var normal = (v1 - v0).cross(v2 - v0).normalized()
		
		# Add triangle
		st.set_normal(normal)
		st.set_uv(uvs[i0])
		st.add_vertex(v0)
		
		st.set_normal(normal)
		st.set_uv(uvs[i1])
		st.add_vertex(v1)
		
		st.set_normal(normal)
		st.set_uv(uvs[i2])
		st.add_vertex(v2)
	
	st.generate_normals()
	var mesh = st.commit()
	
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

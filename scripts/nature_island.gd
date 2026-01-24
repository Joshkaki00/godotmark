extends Node3D
## Nature Island - 0.5 Acre Static Scene
## Loads and positions all 85 nature assets across beach, forest, and cliff zones

@onready var beach_zone = $Terrain/BeachZone
@onready var forest_zone = $Terrain/ForestZone
@onready var cliff_zone = $Terrain/CliffZone
@onready var audio = $AudioStreamPlayer
@onready var camera = $Camera3D
@onready var sun_light = $DirectionalLight3D

# Island dimensions (0.5 acres ≈ 2023 m² ≈ 45m × 45m)
const ISLAND_SIZE = Vector2(45, 45)
const BEACH_DEPTH = 15.0  # Beach zone depth
const FOREST_DEPTH = 15.0  # Forest zone depth
const CLIFF_DEPTH = 15.0  # Cliff zone depth

# All 85 nature assets organized by category
var ground_textures = [
	"coast_sand_01_2k.gltf", "coast_sand_02_2k.gltf", "coast_sand_rocks_02_2k.gltf",
	"brown_mud_2k.gltf", "brown_mud_02_2k.gltf", "brown_mud_03_2k.gltf", "brown_mud_dry_2k.gltf",
	"burned_ground_01_2k.gltf", "red_dirt_mud_01_2k.gltf", "rocky_trail_2k.gltf",
	"park_dirt_2k.gltf", "leaves_forest_ground_2k.gltf", "forrest_ground_01_2k.gltf",
	"forrest_ground_03_2k.gltf", "forest_leaves_02_2k.gltf", "forest_leaves_03_2k.gltf",
	"forest_ground_04_2k.gltf", "forest_floor_2k.gltf", "mountainside_2k.gltf"
]

var grass_patches = [
	"moss_01_2k.gltf", "grass_medium_02_2k.gltf", "grass_medium_01_2k.gltf",
	"grass_bermuda_01_2k.gltf"
]

var succulents = [
	"othonna_cerarioides_2k.gltf", "crystalline_iceplant_2k.gltf",
	"cheiridopsis_succulent_2k.gltf"
]

var flowers = [
	"flower_ursinia_2k.gltf", "flower_stinkkruid_2k.gltf", "flower_heliophila_2k.gltf",
	"flower_gazania_2k.gltf", "flower_empodium_2k.gltf", "dandelion_01_2k.gltf",
	"celandine_01_2k.gltf"
]

var plants = [
	"weed_plant_02_2k.gltf", "periwinkle_plant_2k.gltf", "nettle_plant_2k.gltf",
	"fern_02_2k.gltf", "pachira_aquatica_01_2k.gltf", "calathea_orbifolia_01_2k.gltf",
	"anthurium_botany_01_2k.gltf"
]

var shrubs = [
	"wild_rooibos_bush_2k.gltf", "shrub_04_2k.gltf", "shrub_03_2k.gltf",
	"shrub_02_2k.gltf", "shrub_01_2k.gltf"
]

var debris = [
	"dry_branches_medium_01_2k.gltf", "bark_debris_01_2k.gltf", "single_root_2k.gltf",
	"pine_roots_2k.gltf"
]

var stumps = [
	"tree_stump_02_2k.gltf", "tree_stump_01_2k.gltf", "dead_quiver_trunk_2k.gltf",
	"dead_tree_trunk_02_2k.gltf", "dead_tree_trunk_2k.gltf"
]

var rocks_small = [
	"moon_rock_01_2k.gltf", "stone_01_2k.gltf", "rock_moss_set_02_2k.gltf",
	"rock_moss_set_01_2k.gltf", "sand_rocks_small_01_2k.gltf"
]

var rocks_large = [
	"rock_face_03_2k.gltf", "rock_face_02_2k.gltf", "rock_face_01_2k.gltf",
	"namaqualand_cliff_02_2k.gltf", "namaqualand_boulder_03_2k.gltf",
	"namaqualand_boulder_02_2k.gltf", "boulder_01_2k.gltf"
]

var roots = [
	"root_cluster_02_2k.gltf", "root_cluster_01_2k.gltf"
]

var coast_rocks = [
	"coast_line_02_2k.gltf", "coast_land_rocks_04_2k.gltf", "coast_rocks_03_2k.gltf",
	"coast_rocks_02_2k.gltf"
]

var trees_small = [
	"searsia_lucida_2k.gltf", "searsia_burchellii_2k.gltf", "pine_sapling_small_2k.gltf",
	"fir_sapling_medium_2k.gltf", "fir_sapling_2k.gltf", "tree_small_02_2k.gltf"
]

var trees_medium = [
	"island_tree_03_2k.gltf", "island_tree_02_2k.gltf", "island_tree_01_2k.gltf",
	"quiver_tree_02_2k.gltf", "quiver_tree_01_2k.gltf"
]

var trees_large = [
	"jacaranda_tree_2k.gltf", "fir_tree_01_2k.gltf"
]

# Loaded model instances
var loaded_models = []

func _ready():
	print("\n[NatureIsland] Starting island construction...")
	print("[NatureIsland] Island size: %.1f × %.1f meters (0.5 acres)" % [ISLAND_SIZE.x, ISLAND_SIZE.y])
	
	# Load all 85 models
	await load_all_models()
	
	# Build the island zones
	build_beach_zone()
	build_forest_zone()
	build_cliff_zone()
	
	# Start ambient music
	audio.play()
	
	print("[NatureIsland] Island construction complete! Total objects: %d" % loaded_models.size())

func load_all_models():
	"""Load all 85 glTF models from the nature-benchmark folder"""
	var base_path = "res://art/nature-benchmark/"
	var all_assets = []
	
	# Combine all asset categories
	all_assets.append_array(ground_textures)
	all_assets.append_array(grass_patches)
	all_assets.append_array(succulents)
	all_assets.append_array(flowers)
	all_assets.append_array(plants)
	all_assets.append_array(shrubs)
	all_assets.append_array(debris)
	all_assets.append_array(stumps)
	all_assets.append_array(rocks_small)
	all_assets.append_array(rocks_large)
	all_assets.append_array(roots)
	all_assets.append_array(coast_rocks)
	all_assets.append_array(trees_small)
	all_assets.append_array(trees_medium)
	all_assets.append_array(trees_large)
	
	print("[NatureIsland] Loading %d models..." % all_assets.size())
	
	for asset_file in all_assets:
		var full_path = base_path + asset_file
		var scene = load(full_path)
		
		if scene:
			loaded_models.append({
				"name": asset_file.get_basename(),
				"scene": scene,
				"category": get_asset_category(asset_file)
			})
		else:
			push_error("[NatureIsland] Failed to load: %s" % full_path)
		
		# Yield every 5 models to prevent frame drops
		if loaded_models.size() % 5 == 0:
			await get_tree().process_frame
	
	print("[NatureIsland] Loaded %d models successfully" % loaded_models.size())

func get_asset_category(filename: String) -> String:
	"""Determine asset category from filename"""
	if filename in ground_textures:
		return "ground"
	elif filename in grass_patches:
		return "grass"
	elif filename in succulents:
		return "succulent"
	elif filename in flowers:
		return "flower"
	elif filename in plants:
		return "plant"
	elif filename in shrubs:
		return "shrub"
	elif filename in debris:
		return "debris"
	elif filename in stumps:
		return "stump"
	elif filename in rocks_small:
		return "rock_small"
	elif filename in rocks_large:
		return "rock_large"
	elif filename in roots:
		return "root"
	elif filename in coast_rocks:
		return "coast_rock"
	elif filename in trees_small:
		return "tree_small"
	elif filename in trees_medium:
		return "tree_medium"
	elif filename in trees_large:
		return "tree_large"
	return "unknown"

func build_beach_zone():
	"""Construct the beach zone (sandy area near water)"""
	print("[NatureIsland] Building beach zone...")
	
	# Ground textures (coast sand)
	place_models_by_category("ground", beach_zone, 15, 1.0, ["coast_sand", "coast_rocks"])
	
	# Coast rocks along water edge
	place_models_by_category("coast_rock", beach_zone, 8, 1.2)
	
	# Small rocks scattered
	place_models_by_category("rock_small", beach_zone, 12, 0.8)
	
	# Grass patches
	place_models_by_category("grass", beach_zone, 20, 0.6)
	
	# Succulents and coastal flowers
	place_models_by_category("succulent", beach_zone, 15, 0.5)
	place_models_by_category("flower", beach_zone, 25, 0.4)
	
	# Small shrubs
	place_models_by_category("shrub", beach_zone, 10, 0.7)
	
	# Small trees (sparse)
	place_models_by_category("tree_small", beach_zone, 5, 1.0)

func build_forest_zone():
	"""Construct the forest zone (dense vegetation)"""
	print("[NatureIsland] Building forest zone...")
	
	# Ground textures (forest floor, leaves)
	place_models_by_category("ground", forest_zone, 20, 1.0, ["forest", "leaves"])
	
	# Dense grass coverage
	place_models_by_category("grass", forest_zone, 40, 0.5)
	
	# Plants and ferns
	place_models_by_category("plant", forest_zone, 30, 0.6)
	
	# Flowers scattered throughout
	place_models_by_category("flower", forest_zone, 35, 0.4)
	
	# Shrubs (medium density)
	place_models_by_category("shrub", forest_zone, 20, 0.8)
	
	# Roots and debris
	place_models_by_category("root", forest_zone, 8, 1.0)
	place_models_by_category("debris", forest_zone, 15, 0.9)
	
	# Tree stumps
	place_models_by_category("stump", forest_zone, 6, 1.1)
	
	# Small rocks with moss
	place_models_by_category("rock_small", forest_zone, 10, 0.7)
	
	# Trees (dense forest)
	place_models_by_category("tree_small", forest_zone, 15, 1.0)
	place_models_by_category("tree_medium", forest_zone, 10, 1.2)
	place_models_by_category("tree_large", forest_zone, 8, 1.5)

func build_cliff_zone():
	"""Construct the cliff zone (rocky elevation)"""
	print("[NatureIsland] Building cliff zone...")
	
	# Ground textures (rocky, mountainside)
	place_models_by_category("ground", cliff_zone, 18, 1.0, ["rocky", "mountain", "burned"])
	
	# Large rock formations
	place_models_by_category("rock_large", cliff_zone, 12, 1.5)
	
	# Small rocks
	place_models_by_category("rock_small", cliff_zone, 20, 0.9)
	
	# Sparse grass
	place_models_by_category("grass", cliff_zone, 15, 0.5)
	
	# Hardy plants and flowers
	place_models_by_category("plant", cliff_zone, 10, 0.5)
	place_models_by_category("flower", cliff_zone, 15, 0.3)
	
	# Dead trees and stumps
	place_models_by_category("stump", cliff_zone, 5, 1.0)
	
	# Small shrubs (sparse)
	place_models_by_category("shrub", cliff_zone, 8, 0.6)
	
	# Small hardy trees
	place_models_by_category("tree_small", cliff_zone, 6, 0.9)

func place_models_by_category(category: String, parent_zone: Node3D, count: int, scale_multiplier: float, filter_keywords: Array = []):
	"""Place multiple instances of models from a category"""
	var models_in_category = loaded_models.filter(func(m): 
		if m.category != category:
			return false
		if filter_keywords.is_empty():
			return true
		for keyword in filter_keywords:
			if m.name.to_lower().contains(keyword.to_lower()):
				return true
		return false
	)
	
	if models_in_category.is_empty():
		return
	
	# Calculate zone bounds relative to parent
	var zone_offset = parent_zone.position
	var zone_min = Vector3(
		zone_offset.x - ISLAND_SIZE.x / 2,
		0,
		zone_offset.z - BEACH_DEPTH / 2
	)
	var zone_max = Vector3(
		zone_offset.x + ISLAND_SIZE.x / 2,
		0,
		zone_offset.z + BEACH_DEPTH / 2
	)
	
	for i in range(count):
		# Pick random model from category
		var model_data = models_in_category[randi() % models_in_category.size()]
		var instance = model_data.scene.instantiate() as Node3D
		
		if instance:
			# Random position within zone
			var pos = Vector3(
				randf_range(zone_min.x, zone_max.x),
				0,
				randf_range(zone_min.z, zone_max.z)
			)
			
			# Random rotation
			var rot_y = randf_range(0, TAU)
			
			# Scale variation
			var base_scale = 0.5  # Conservative base scale
			var scale_var = randf_range(0.8, 1.2)
			var final_scale = base_scale * scale_multiplier * scale_var
			
			instance.position = pos
			instance.rotation.y = rot_y
			instance.scale = Vector3.ONE * final_scale
			
			parent_zone.add_child(instance)

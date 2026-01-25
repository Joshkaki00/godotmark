extends Camera3D
## Optimized Cinematic Camera - NO per-frame look_at() calls
## Pre-calculates all transforms at startup for maximum performance

# Pre-calculated transforms (one every 3 seconds for Raspberry Pi optimization)
var transform_cache: Array[Transform3D] = []
var cache_duration: float = 176.0  # Total benchmark duration
var cache_rate: float = 3.0  # One transform every 3 seconds (60 total vs 177)

# Camera path keyframes (cinematic tour of forested island)
var keyframes = [
	# Start: Aerial view from ocean side
	{"time": 0.0, "position": Vector3(-40, 25, 0), "look_at": Vector3(0, 8, 0)},
	# Approach: Move toward island, descend
	{"time": 29.0, "position": Vector3(-20, 18, 15), "look_at": Vector3(5, 5, 0)},
	# Interior: Enter forest, low angle through trees
	{"time": 58.0, "position": Vector3(10, 6, -10), "look_at": Vector3(0, 4, 5)},
	# Clearing: Rise up over clearing, show undergrowth
	{"time": 88.0, "position": Vector3(-5, 12, 8), "look_at": Vector3(3, 2, -5)},
	# Coastal: Move to rocky outcrop, show bay
	{"time": 117.0, "position": Vector3(20, 10, -20), "look_at": Vector3(0, 3, 0)},
	# Departure: Pull back, rise up, show whole island
	{"time": 146.0, "position": Vector3(15, 22, 25), "look_at": Vector3(0, 6, 0)},
	# Final: Aerial view from opposite side
	{"time": 176.0, "position": Vector3(40, 25, 0), "look_at": Vector3(0, 8, 0)},
]

var parent_node: Node3D

func _ready():
	parent_node = get_parent()
	# PRE-CALCULATE all transforms at startup
	pre_calculate_transforms()
	print("[OptimizedCamera] Pre-calculated %d transforms" % transform_cache.size())

func pre_calculate_transforms():
	"""Pre-calculate ALL camera transforms to avoid per-frame look_at()"""
	var num_frames = int(cache_duration / cache_rate) + 1
	transform_cache.resize(num_frames)
	
	for i in range(num_frames):
		var time = i * cache_rate
		transform_cache[i] = calculate_transform_at_time(time)

func calculate_transform_at_time(time: float) -> Transform3D:
	"""Calculate transform for given time (used during pre-calculation)"""
	# Find keyframes to interpolate between
	var prev_kf = keyframes[0]
	var next_kf = keyframes[-1]
	
	for j in range(keyframes.size() - 1):
		if time >= keyframes[j]["time"] and time < keyframes[j + 1]["time"]:
			prev_kf = keyframes[j]
			next_kf = keyframes[j + 1]
			break
	
	# Interpolation factor
	var time_range = next_kf["time"] - prev_kf["time"]
	var t = (time - prev_kf["time"]) / time_range if time_range > 0 else 0.0
	t = ease_in_out_cubic(t)
	
	# Interpolate position
	var pos = prev_kf["position"].lerp(next_kf["position"], t)
	var target = prev_kf["look_at"].lerp(next_kf["look_at"], t)
	
	# Create transform with look_at (ONLY during pre-calculation, not per frame!)
	var temp_transform = Transform3D()
	temp_transform.origin = pos
	temp_transform = temp_transform.looking_at(target, Vector3.UP)
	
	return temp_transform

func _process(_delta):
	"""Fast lookup from pre-calculated transforms (no look_at call!)"""
	if not parent_node or transform_cache.is_empty():
		return
	
	var current_time = parent_node.timeline if "timeline" in parent_node else 0.0
	
	# Get cached transform indices
	var idx = int(current_time / cache_rate)
	var next_idx = min(idx + 1, transform_cache.size() - 1)
	
	# Interpolation factor between cached frames
	var t = fmod(current_time, cache_rate) / cache_rate
	
	# Slerp between cached transforms (FAST - just quaternion interpolation)
	var transform_a = transform_cache[idx]
	var transform_b = transform_cache[next_idx]
	
	var new_basis = Basis(transform_a.basis.get_rotation_quaternion().slerp(
		transform_b.basis.get_rotation_quaternion(), t))
	var new_origin = transform_a.origin.lerp(transform_b.origin, t)
	
	transform = Transform3D(new_basis, new_origin)

func ease_in_out_cubic(t: float) -> float:
	"""Smooth easing function for cinematic motion"""
	if t < 0.5:
		return 4 * t * t * t
	else:
		var f = (2 * t - 2)
		return 1 + 0.5 * f * f * f

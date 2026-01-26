extends Camera3D
## Optimized Cinematic Camera - NO per-frame look_at() calls
## Pre-calculates all transforms at startup for maximum performance

# Pre-calculated transforms (one every 1.5 seconds for smooth motion)
var transform_cache: Array[Transform3D] = []
var cache_duration: float = 60.0  # Total benchmark duration (1 minute)
var cache_rate: float = 1.5  # One transform every 1.5 seconds (40 total - smooth but performant)

# Camera path keyframes (smooth orbit around 0.5-acre island: 30m x 60m)
# Design: Gentle 180° orbit showing different perspectives of the elongated island
var keyframes = [
	# Phase 1: Start - South view, overlooking long axis
	{"time": 0.0, "position": Vector3(0, 15, 40), "look_at": Vector3(0, 2, 0)},
	# Phase 2: Southeast, descending to show rocks
	{"time": 12.0, "position": Vector3(25, 12, 25), "look_at": Vector3(0, 1, 0)},
	# Phase 3: East, side view of island length
	{"time": 24.0, "position": Vector3(30, 10, 0), "look_at": Vector3(0, 2, 0)},
	# Phase 4: Northeast, showing ground details
	{"time": 36.0, "position": Vector3(25, 12, -25), "look_at": Vector3(0, 1, 0)},
	# Phase 5: North, final wide view
	{"time": 48.0, "position": Vector3(0, 15, -40), "look_at": Vector3(0, 2, 0)},
	# End: Northwest, completion
	{"time": 60.0, "position": Vector3(-20, 16, -35), "look_at": Vector3(0, 3, 0)},
]

var parent_node: Node3D

func _ready():
	parent_node = get_parent()
	
	# Set far plane for Raspberry Pi optimization (only render within 50m)
	far = 50.0
	print("[OptimizedCamera] Far plane set to 50m for close-range performance")
	
	# PRE-CALCULATE all transforms at startup
	pre_calculate_transforms()
	print("[OptimizedCamera] Pre-calculated %d transforms (smooth orbit)" % transform_cache.size())

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
	t = ease_in_out_sine(t)  # Gentle, smooth easing for cinematic motion
	
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
	
	# Get cached transform indices (clamp to prevent out-of-bounds access)
	var idx = min(int(current_time / cache_rate), transform_cache.size() - 1)
	var next_idx = min(idx + 1, transform_cache.size() - 1)
	
	# Interpolation factor between cached frames (smooth)
	var t = fmod(current_time, cache_rate) / cache_rate
	t = ease_in_out_sine(t)  # Smooth interpolation between cache points
	
	# Slerp between cached transforms (FAST - just quaternion interpolation)
	var transform_a = transform_cache[idx]
	var transform_b = transform_cache[next_idx]
	
	var new_basis = Basis(transform_a.basis.get_rotation_quaternion().slerp(
		transform_b.basis.get_rotation_quaternion(), t))
	var new_origin = transform_a.origin.lerp(transform_b.origin, t)
	
	transform = Transform3D(new_basis, new_origin)

func ease_in_out_sine(t: float) -> float:
	"""Gentle sine-based easing for smooth, non-nauseating camera motion"""
	return -(cos(PI * t) - 1.0) / 2.0

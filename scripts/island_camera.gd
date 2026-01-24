extends Camera3D
## Cinematic Camera Controller for Nature Island Benchmark
## 6-phase keyframe-based animation with smooth interpolation
## Each phase focuses on different island zones

# Camera keyframes for 6 phases (time, position, look_at)
# Island layout: Beach (+Z), Forest (center), Cliff (-Z)
var keyframes = [
	# Phase 1: Beach Dawn (0-29s) - Low angle, coastal view
	{"time": 0.0, "position": Vector3(10, 2, 40), "look_at": Vector3(0, 0, 35)},
	{"time": 14.5, "position": Vector3(-8, 3, 38), "look_at": Vector3(0, 0, 35)},
	{"time": 29.0, "position": Vector3(5, 2.5, 42), "look_at": Vector3(0, 0, 35)},
	
	# Phase 2: Coastal Morning (29-58s) - Transition from beach to forest
	{"time": 29.0, "position": Vector3(12, 3, 25), "look_at": Vector3(0, 1, 15)},
	{"time": 43.5, "position": Vector3(-10, 4, 20), "look_at": Vector3(0, 2, 10)},
	{"time": 58.0, "position": Vector3(8, 3.5, 22), "look_at": Vector3(0, 1, 12)},
	
	# Phase 3: Forest Midday + Rain (58-87s) - Deep in forest, looking up
	{"time": 58.0, "position": Vector3(5, 2, 5), "look_at": Vector3(0, 4, 0)},
	{"time": 72.5, "position": Vector3(-6, 3, -2), "look_at": Vector3(0, 5, 0)},
	{"time": 87.0, "position": Vector3(7, 2.5, 3), "look_at": Vector3(0, 4.5, 0)},
	
	# Phase 4: Forest Afternoon (87-116s) - Mid-forest, canopy views
	{"time": 87.0, "position": Vector3(-10, 4, 0), "look_at": Vector3(0, 3, 0)},
	{"time": 101.5, "position": Vector3(8, 5, -5), "look_at": Vector3(0, 3, 0)},
	{"time": 116.0, "position": Vector3(-9, 4.5, 2), "look_at": Vector3(0, 3, 0)},
	
	# Phase 5: Cliff Dusk + Fog (116-145s) - Dramatic cliff angles
	{"time": 116.0, "position": Vector3(15, 6, -35), "look_at": Vector3(0, 4, -40)},
	{"time": 130.5, "position": Vector3(-12, 8, -38), "look_at": Vector3(0, 5, -40)},
	{"time": 145.0, "position": Vector3(10, 7, -36), "look_at": Vector3(0, 4.5, -40)},
	
	# Phase 6: Island Night (145-171s) - Pull back for island overview
	{"time": 145.0, "position": Vector3(20, 10, 15), "look_at": Vector3(0, 2, 0)},
	{"time": 158.0, "position": Vector3(-18, 12, 10), "look_at": Vector3(0, 2, 0)},
	{"time": 171.0, "position": Vector3(0, 15, 20), "look_at": Vector3(0, 2, 0)},
	
	# Finale (171-176s) - Hold final position during fade
	{"time": 176.0, "position": Vector3(0, 15, 20), "look_at": Vector3(0, 2, 0)},
]

var island_node: Node3D
var current_phase = 1

func _ready():
	# Get reference to parent island node
	island_node = get_parent()
	
	# Set initial camera position
	if keyframes.size() > 0:
		position = keyframes[0]["position"]
		look_at(keyframes[0]["look_at"])
	
	print("[IslandCamera] Initialized with %d keyframes across 6 phases" % keyframes.size())

func _process(_delta):
	if not island_node:
		return
	
	# Get current timeline from parent
	var current_time = island_node.timeline if "timeline" in island_node else 0.0
	
	# Only animate if warmup is complete
	if "warmup_complete" in island_node and not island_node.warmup_complete:
		return
	
	# Interpolate camera position and rotation
	interpolate_camera(current_time)

func interpolate_camera(current_time: float):
	# Find the two keyframes to interpolate between
	var prev_keyframe = keyframes[0]
	var next_keyframe = keyframes[0]
	
	for i in range(keyframes.size() - 1):
		if current_time >= keyframes[i]["time"] and current_time < keyframes[i + 1]["time"]:
			prev_keyframe = keyframes[i]
			next_keyframe = keyframes[i + 1]
			break
	
	# If we're past the last keyframe, use the last one
	if current_time >= keyframes[-1]["time"]:
		position = keyframes[-1]["position"]
		look_at(keyframes[-1]["look_at"])
		return
	
	# Calculate interpolation factor (0.0 to 1.0)
	var time_range = next_keyframe["time"] - prev_keyframe["time"]
	var time_offset = current_time - prev_keyframe["time"]
	var t = time_offset / time_range if time_range > 0 else 0.0
	
	# Apply easing for smooth motion (ease in-out cubic)
	t = ease_in_out_cubic(t)
	
	# Interpolate position
	var new_pos = prev_keyframe["position"].lerp(next_keyframe["position"], t)
	position = new_pos
	
	# Interpolate look_at target
	var new_target = prev_keyframe["look_at"].lerp(next_keyframe["look_at"], t)
	look_at(new_target)

func ease_in_out_cubic(t: float) -> float:
	# Smooth easing function for cinematic motion
	if t < 0.5:
		return 4 * t * t * t
	else:
		var f = (2 * t - 2)
		return 1 + 0.5 * f * f * f

func move_to_phase(phase_num: int):
	"""Called during phase transitions to smoothly move camera to new zone"""
	current_phase = phase_num
	print("[IslandCamera] Moving to phase %d zone" % phase_num)
	
	# Camera will smoothly interpolate to the keyframes for this phase
	# This method exists for compatibility with the controller's phase transition logic

extends Camera3D
## Cinematic Camera Controller for Model Showcase
## Keyframe-based animation with smooth interpolation

# Camera keyframes (time, position, look_at)
var keyframes = [
	{"time": 0.0, "position": Vector3(0, 0.5, 1.5), "look_at": Vector3(0, 0.3, 0)},
	{"time": 12.0, "position": Vector3(0, 0.5, 1.0), "look_at": Vector3(0, 0.3, 0)},
	{"time": 24.0, "position": Vector3(1.0, 0.6, 1.0), "look_at": Vector3(0, 0.3, 0)},
	{"time": 36.0, "position": Vector3(-1.0, 0.7, 1.0), "look_at": Vector3(0, 0.35, 0)},
	{"time": 48.0, "position": Vector3(-0.8, 0.4, 0.8), "look_at": Vector3(0, 0.25, 0)},
	{"time": 60.0, "position": Vector3(0, 0.5, 1.2), "look_at": Vector3(0, 0.3, 0)},
]

var showcase_node: Node3D

func _ready():
	# Get reference to parent showcase node
	showcase_node = get_parent()
	
	# Set initial camera position
	if keyframes.size() > 0:
		position = keyframes[0]["position"]
		look_at(keyframes[0]["look_at"])

func _process(_delta):
	if not showcase_node:
		return
	
	# Get current timeline from parent
	var current_time = showcase_node.timeline if "timeline" in showcase_node else 0.0
	
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


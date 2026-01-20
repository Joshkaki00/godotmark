extends Control
## Real-time metrics overlay for GPU Basics benchmark

var fps_label
var frame_time_label
var cpu_label
var temp_label
var gpu_label
var test_label
var progress_bar
var timeline_label

func _ready():
	# Get node references
	fps_label = $Panel/MarginContainer/VBoxContainer/FPSLabel
	frame_time_label = $Panel/MarginContainer/VBoxContainer/FrameTimeLabel
	cpu_label = $Panel/MarginContainer/VBoxContainer/CPULabel
	temp_label = $Panel/MarginContainer/VBoxContainer/TempLabel
	gpu_label = $Panel/MarginContainer/VBoxContainer/GPULabel
	test_label = $Panel/MarginContainer/VBoxContainer/TestLabel
	progress_bar = $Panel/MarginContainer/VBoxContainer/ProgressBar
	timeline_label = $Panel/MarginContainer/VBoxContainer/TimelineLabel
	
	# Ensure we're always on top
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)

func update_metrics(fps: float, frame_time: float, cpu_usage: float, temp: float, gpu_usage: float):
	"""Update performance metrics with color-coded FPS"""
	if not fps_label:
		return
	
	# Color-coded FPS (green >30, yellow 20-30, red <20)
	var fps_color = Color.GREEN if fps >= 30 else (Color.YELLOW if fps >= 20 else Color.RED)
	fps_label.text = "FPS: %.1f" % fps
	fps_label.add_theme_color_override("font_color", fps_color)
	
	frame_time_label.text = "Frame: %.2f ms" % frame_time
	cpu_label.text = "CPU: %.1f%%" % cpu_usage
	temp_label.text = "Temp: %.1f°C" % temp
	gpu_label.text = "GPU: %.1f%%" % gpu_usage

func update_test(test_name: String):
	"""Update current test display"""
	if not test_label:
		return
	test_label.text = "Test: %s" % test_name

func update_progress(current_time: float, total_time: float):
	"""Update progress bar and timeline"""
	if not progress_bar:
		return
	progress_bar.value = (current_time / total_time) * 100
	var mins = int(current_time / 60)
	var secs = int(current_time) % 60
	timeline_label.text = "%02d:%02d / 01:00" % [mins, secs]

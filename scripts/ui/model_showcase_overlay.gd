extends Control
## Real-time metrics overlay for Model Showcase benchmark

@onready var fps_label = $Panel/MarginContainer/VBoxContainer/FPSLabel
@onready var frame_time_label = $Panel/MarginContainer/VBoxContainer/FrameTimeLabel
@onready var cpu_label = $Panel/MarginContainer/VBoxContainer/CPULabel
@onready var temp_label = $Panel/MarginContainer/VBoxContainer/TempLabel
@onready var gpu_label = $Panel/MarginContainer/VBoxContainer/GPULabel
@onready var phase_label = $Panel/MarginContainer/VBoxContainer/PhaseLabel
@onready var progress_bar = $Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var timeline_label = $Panel/MarginContainer/VBoxContainer/TimelineLabel

func _ready():
	# Ensure we're always on top
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)

func update_metrics(fps: float, frame_time: float, cpu_usage: float, temp: float, gpu_usage: float):
	"""Update performance metrics with color-coded FPS"""
	
	# Color-coded FPS (green >30, yellow 20-30, red <20)
	var fps_color = Color.GREEN if fps >= 30 else (Color.YELLOW if fps >= 20 else Color.RED)
	fps_label.text = "FPS: %.1f" % fps
	fps_label.add_theme_color_override("font_color", fps_color)
	
	frame_time_label.text = "Frame: %.2f ms" % frame_time
	cpu_label.text = "CPU: %.1f%%" % cpu_usage
	temp_label.text = "Temp: %.1f°C" % temp
	gpu_label.text = "GPU: %.1f%%" % gpu_usage

func update_phase(phase_num: int, phase_name: String):
	"""Update current phase display"""
	phase_label.text = "Phase %d: %s" % [phase_num, phase_name]

func update_progress(current_time: float, total_time: float):
	"""Update progress bar and timeline"""
	progress_bar.value = (current_time / total_time) * 100
	var mins = int(current_time / 60)
	var secs = int(current_time) % 60
	timeline_label.text = "%02d:%02d / 01:00" % [mins, secs]


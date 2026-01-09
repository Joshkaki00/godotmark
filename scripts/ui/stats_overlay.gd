extends Control

var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager

@onready var fps_label = $StatsPanel/MarginContainer/VBoxContainer/FPSLabel
@onready var frame_time_label = $StatsPanel/MarginContainer/VBoxContainer/FrameTimeLabel
@onready var quality_label = $StatsPanel/MarginContainer/VBoxContainer/QualityLabel
@onready var load_label = $StatsPanel/MarginContainer/VBoxContainer/LoadLabel
@onready var cpu_label = $StatsPanel/MarginContainer/VBoxContainer/CPULabel
@onready var temp_label = $StatsPanel/MarginContainer/VBoxContainer/TempLabel
@onready var status_label = $StatsPanel/MarginContainer/VBoxContainer/StatusLabel
@onready var progress_bar = $ProgressBar
@onready var progress_label = $ProgressBar/ProgressLabel
@onready var throttle_warning = $ThrottleWarning

func _ready():
	# Will be initialized by main.gd
	pass

func set_monitors(pm: PerformanceMonitor, qm: AdaptiveQualityManager):
	perf_monitor = pm
	quality_manager = qm

func _process(_delta):
	if not perf_monitor or not quality_manager:
		return
	
	# FPS with color coding
	var fps = perf_monitor.get_avg_fps()
	fps_label.text = "FPS: %.1f" % fps
	if fps > 40:
		fps_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	elif fps > 25:
		fps_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	else:
		fps_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	
	# Frame time
	var frame_time = perf_monitor.get_current_frametime_ms()
	frame_time_label.text = "Frame: %.1fms" % frame_time
	
	# Quality preset
	var quality = quality_manager.get_quality_name()
	quality_label.text = "Quality: %s" % quality
	
	# Thermal
	var temp = perf_monitor.get_temperature()
	temp_label.text = "Temp: %.1f°C" % temp
	throttle_warning.visible = perf_monitor.is_throttling()


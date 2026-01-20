extends Control
## Loading Screen for Benchmark Warmup Phase
## Displays progress bar and status messages during system initialization

@onready var progress_bar = $Panel/VBoxContainer/ProgressBar
@onready var status_label = $Panel/VBoxContainer/StatusLabel
@onready var timer_label = $Panel/VBoxContainer/TimerLabel

func _ready():
	# Ensure nodes are available
	if not progress_bar:
		progress_bar = $Panel/VBoxContainer/ProgressBar
	if not status_label:
		status_label = $Panel/VBoxContainer/StatusLabel
	if not timer_label:
		timer_label = $Panel/VBoxContainer/TimerLabel

func update_progress(percent: float, status: String):
	"""Update progress bar and status text"""
	if progress_bar:
		progress_bar.value = percent
	if status_label:
		status_label.text = status

func update_timer(seconds: float):
	"""Update countdown timer"""
	if timer_label:
		timer_label.text = "Time remaining: %.1fs" % seconds


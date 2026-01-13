extends Node

# References to systems (set by main.gd)
var quality_manager: AdaptiveQualityManager
var stress_test: ProgressiveStressTest
var is_paused: bool = false
var verbose_enabled: bool = false

func _ready():
	# Ensure this node always processes, even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[DebugController] Ready - Keys: Space, Q/E, R, T, V, M, Esc")

func set_systems(qm: AdaptiveQualityManager, st: ProgressiveStressTest):
	quality_manager = qm
	stress_test = st

func _input(event: InputEvent):
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_SPACE:
			toggle_pause()
		KEY_Q:
			decrease_quality()
		KEY_E:
			increase_quality()
		KEY_R:
			reset_benchmark()
		KEY_T:
			toggle_quick_test()
		KEY_V:
			toggle_verbose()
		KEY_M:
			launch_model_showcase()
		KEY_ESCAPE:
			print("[DebugController] Exiting...")
			get_tree().quit()

func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	print("[DebugController] ", "PAUSED" if is_paused else "RESUMED")

func decrease_quality():
	if not quality_manager:
		return
	var current = quality_manager.get_quality_preset()
	if current > 0:
		quality_manager.set_quality_preset(current - 1)
		quality_manager.reset_hysteresis()  # Reset adaptive quality counters
		print("[DebugController] Quality: ", quality_manager.get_quality_name(), " (manual)")

func increase_quality():
	if not quality_manager:
		return
	var current = quality_manager.get_quality_preset()
	if current < 4:  # ULTRA = 4
		quality_manager.set_quality_preset(current + 1)
		quality_manager.reset_hysteresis()  # Reset adaptive quality counters
		print("[DebugController] Quality: ", quality_manager.get_quality_name(), " (manual)")

func reset_benchmark():
	if stress_test:
		stress_test.reset_test()
	print("[DebugController] Benchmark reset")

func toggle_quick_test():
	if not stress_test:
		return
	var enabled = not stress_test.get_quick_test_mode()
	stress_test.set_quick_test_mode(enabled, 10.0)
	print("[DebugController] Quick test mode: ", "ON (10s)" if enabled else "OFF (60s)")

func toggle_verbose():
	verbose_enabled = not verbose_enabled
	
	# Get perf_monitor from main scene
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.perf_monitor:
		main.perf_monitor.set_verbose_logging(verbose_enabled)
	
	# Enable for other systems
	if quality_manager:
		quality_manager.set_verbose_logging(verbose_enabled)
	if stress_test:
		stress_test.set_verbose_logging(verbose_enabled)
	
	print("[DebugController] Verbose logging: ", "ON" if verbose_enabled else "OFF")

func launch_model_showcase():
	print("[DebugController] Launching Model Showcase...")
	
	# Load the scene
	var showcase_scene = load("res://scenes/model_showcase.tscn")
	var showcase_instance = showcase_scene.instantiate()
	
	# Hide main scene UI
	var main = get_tree().root.get_node("Main")
	if main:
		# Hide UI elements
		if main.has_node("UI"):
			main.get_node("UI").visible = false
		if main.has_node("DebugController"):
			main.get_node("DebugController").process_mode = Node.PROCESS_MODE_DISABLED
		
		# Add showcase as child of root (deferred for proper initialization)
		get_tree().root.call_deferred("add_child", showcase_instance)
		
		# Wait a frame then ensure camera is current
		await get_tree().process_frame
		if showcase_instance.has_node("Camera3D"):
			var cam = showcase_instance.get_node("Camera3D")
			cam.make_current()
			print("[DebugController] Camera set as current")
		
		print("[DebugController] Model Showcase launched (Main scene preserved)")
	else:
		print("[DebugController] ERROR: Could not find Main scene")

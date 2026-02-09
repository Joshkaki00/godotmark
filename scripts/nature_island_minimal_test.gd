extends Node3D
## MINIMAL TEST: Nature Island Base Scene Only (NO assets)
## This will help isolate if the problem is in the base scene or the nature assets

@onready var ocean = $Ocean
@onready var ground = $Ground
@onready var camera = $Camera3D
@onready var light = $DirectionalLight3D
@onready var metrics_overlay = $MetricsOverlay

var timeline = 0.0

func _ready():
	print("\n========================================")
	print("[MINIMAL TEST] Base scene only - NO nature assets")
	print("========================================\n")
	
	# Set title
	if metrics_overlay and metrics_overlay.has_method("set_benchmark_title"):
		metrics_overlay.set_benchmark_title("MINIMAL TEST - BASE SCENE ONLY")
	
	# Disable physics
	PhysicsServer3D.set_active(false)
	
	print("[MINIMAL TEST] Scene contains:")
	print("  - Ocean: 80×80m plane, 4×4 subdiv, StandardMaterial3D")
	print("  - Ground: 30×60m plane, 1×1 subdiv, StandardMaterial3D")
	print("  - Camera (cinematic path)")
	print("  - DirectionalLight3D")
	print("  - NO nature assets at all")
	print("\nExpected FPS on RPi 5:")
	print("  - If 30+ FPS: Base scene is fine, problem is in nature assets")
	print("  - If 4.5 FPS: Problem is in base scene (ocean/ground/camera/light)")

func _process(delta: float):
	timeline += delta
	update_metrics()
	
	# Exit after 10 seconds
	if timeline >= 10.0:
		print("\n[MINIMAL TEST] Complete!")
		print("Exiting to menu...")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func update_metrics():
	var fps = Engine.get_frames_per_second()
	var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	
	if metrics_overlay:
		metrics_overlay.update_metrics(fps, frame_time, 0, 0, 0)
		metrics_overlay.update_progress(timeline, 10.0)
		
		# Phase display
		if timeline < 5.0:
			metrics_overlay.update_phase(1, "Testing Base Scene (5s)")
		else:
			metrics_overlay.update_phase(2, "Final Measurements (5s)")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("[MINIMAL TEST] ESC pressed - exiting")
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

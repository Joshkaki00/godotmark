extends Node3D

## Ultra-Minimal Nature Island Test
## Just ocean + 5 trees to isolate FPS bottleneck
## Designed to find the exact cause of 7.5 FPS issue

@onready var camera: Camera3D = $Camera3D
@onready var ocean: MeshInstance3D = $Ocean
@onready var metrics_overlay = $MetricsOverlay

var multimesh_trees: MultiMeshInstance3D
var perf_monitor: PerformanceMonitor
var timeline: float = 0.0

const TEST_DURATION = 30.0  # 30 second test

func _ready():
	print("[MinimalTest] ========================================")
	print("[MinimalTest] ULTRA-MINIMAL NATURE ISLAND TEST")
	print("[MinimalTest] Target: Isolate 7.5 FPS bottleneck")
	print("[MinimalTest] ========================================\n")
	
	# Force VSync off
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("[MinimalTest] VSync disabled")
	
	# Setup performance monitor
	perf_monitor = PerformanceMonitor.new()
	print("[MinimalTest] Performance monitor initialized")
	
	# Set benchmark title
	if metrics_overlay and metrics_overlay.has_method("set_benchmark_title"):
		metrics_overlay.set_benchmark_title("MINIMAL TEST (5 TREES)")
	
	# Create 5 simple sphere trees in a circle
	create_minimal_trees()
	
	# Setup static camera (no movement to eliminate interpolation overhead)
	camera.position = Vector3(0, 10, 15)
	camera.look_at(Vector3(0, 0, 0))
	camera.far = 50.0
	print("[MinimalTest] Static camera at position (0, 10, 15)")
	
	print("[MinimalTest] Test started with:")
	print("  - Ocean: 80x80m, 4x4 subdivisions")
	print("  - Trees: 5 sphere primitives (ultra-simple)")
	print("  - Camera: Static (no movement)")
	print("  - Audio: None")
	print("  - Shaders: Basic unshaded only")
	print("  - Duration: 30 seconds\n")

func create_minimal_trees():
	"""Create exactly 5 trees in a circle using simple sphere primitives"""
	var tree_mesh = SphereMesh.new()
	tree_mesh.radius = 2.0
	tree_mesh.height = 4.0
	tree_mesh.radial_segments = 8  # Low poly
	tree_mesh.rings = 4
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.2, 0.5, 0.2)  # Green
	mat.cull_mode = BaseMaterial3D.CULL_BACK
	
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = 5
	multimesh.mesh = tree_mesh
	
	# Place 5 trees in a circle (radius 8m)
	for i in range(5):
		var angle = (i / 5.0) * TAU
		var pos = Vector3(cos(angle) * 8.0, 0, sin(angle) * 8.0)
		var transform = Transform3D(Basis(), pos)
		multimesh.set_instance_transform(i, transform)
	
	multimesh_trees = MultiMeshInstance3D.new()
	multimesh_trees.multimesh = multimesh
	multimesh_trees.material_override = mat
	add_child(multimesh_trees)
	
	print("[MinimalTest] Created 5 sphere trees (8 segments x 4 rings)")

func _process(delta):
	timeline += delta
	
	# Profile rendering every frame
	profile_rendering_pipeline(delta)
	
	# Update metrics
	if perf_monitor:
		perf_monitor.update(delta)
		var fps = perf_monitor.get_current_fps()
		var frame_time = perf_monitor.get_current_frametime_ms()
		var cpu = perf_monitor.get_cpu_usage()
		var temp = perf_monitor.get_temperature()
		var gpu = perf_monitor.get_gpu_usage()
		
		if metrics_overlay.has_method("update_metrics"):
			metrics_overlay.update_metrics(fps, frame_time, cpu, temp, gpu)
		if metrics_overlay.has_method("update_progress"):
			metrics_overlay.update_progress(timeline, TEST_DURATION)
	
	# Exit after 30 seconds
	if timeline >= TEST_DURATION:
		print("\n[MinimalTest] ========================================")
		print("[MinimalTest] Test complete after 30s")
		print("[MinimalTest] ========================================")
		get_tree().quit()

func profile_rendering_pipeline(delta: float):
	"""Comprehensive rendering pipeline profiling to identify bottlenecks"""
	
	# 1. VSync verification
	var vsync_mode = DisplayServer.window_get_vsync_mode()
	var vsync_names = ["DISABLED", "ENABLED", "ADAPTIVE", "MAILBOX"]
	
	# 2. RenderingServer statistics
	var render_info = {
		"objects_drawn": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		"primitives_drawn": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		"draw_calls": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		"texture_memory_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED) / 1024.0 / 1024.0,
		"video_memory_mb": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1024.0 / 1024.0,
	}
	
	# 3. Frame timing breakdown
	var frame_ms = delta * 1000.0
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var render_time = frame_ms - process_time - physics_time
	
	# 4. GPU driver diagnostics
	var gpu_driver = RenderingServer.get_video_adapter_name()
	var gpu_vendor = RenderingServer.get_video_adapter_vendor()
	
	# Log every 60 frames for detailed diagnostics
	if Engine.get_process_frames() % 60 == 0:
		print("[PROFILE] VSync: %s | Draw Calls: %d | Objects: %d | Primitives: %d" % 
			[vsync_names[vsync_mode], render_info.draw_calls, render_info.objects_drawn, render_info.primitives_drawn])
		print("[PROFILE] VRAM: %.1fMB | Texture Mem: %.1fMB" % 
			[render_info.video_memory_mb, render_info.texture_memory_mb])
		print("[PROFILE] Frame: %.1fms (CPU: %.1fms, Physics: %.1fms, Render: %.1fms)" % 
			[frame_ms, process_time, physics_time, render_time])
		print("[PROFILE] GPU: %s (%s)" % [gpu_driver, gpu_vendor])

func _input(event):
	"""Handle keyboard input for early exit"""
	if event.is_action_pressed("ui_cancel"):
		print("\n[MinimalTest] Cancelled by user")
		get_tree().quit()

extends Node3D
## Minimal GDScript wrapper for GPUBasicsScene C++ controller
## UI is handled by GDScript, all logic is in C++

var cpp_controller: GPUBasicsScene
var benchmark_running = false
var benchmark_timer = 0.0
var benchmark_duration = 60.0

# Performance monitoring
var perf_monitor: PerformanceMonitor
var platform_detector

# Metrics tracking
var metrics = []
var current_test_name = "Initializing..."

# Threaded loading state
var is_loading = false
var loader = null
@onready var loading_screen = $"../LoadingScreen"
@onready var metrics_overlay = $"../MetricsOverlay"

func _ready():
	print("\n========================================")
	print("[GPUBasics] Starting GPU Basics Benchmark")
	print("========================================\n")
	
	# Get performance systems from main scene if available
	var main = get_tree().root.get_node_or_null("Main")
	if main:
		perf_monitor = main.perf_monitor
		platform_detector = main.platform_detector
		print("[GPUBasics] Systems found: perf=%s, platform=%s" % [
			perf_monitor != null, platform_detector != null
		])
	else:
		print("[GPUBasics] WARNING: Main scene not found, creating standalone systems")
		# Create standalone performance monitor
		perf_monitor = PerformanceMonitor.new()
		platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		print("[GPUBasics] Standalone systems created")
	
	# Pre-allocate metrics array (60 seconds @ 60 FPS = ~3600 samples)
	metrics.resize(3600)
	metrics.clear()
	
	# Create C++ controller
	cpp_controller = GPUBasicsScene.new()
	add_child(cpp_controller)
	
	# Start benchmark (60 seconds)
	cpp_controller.start_test(benchmark_duration)
	benchmark_running = true
	current_test_name = "GPU Stress Test"
	
	# Initialize metrics overlay
	if metrics_overlay:
		metrics_overlay.update_test(current_test_name)
	
	print("[GPUBasics] Benchmark started - Press ESC to return to menu")

func _process(delta):
	# Handle threaded loading
	if is_loading and loader:
		loader.update_progress()
		var progress = loader.get_overall_progress()
		var percent = progress * 100.0
		
		if loading_screen:
			loading_screen.update_progress(percent, "Returning to menu... %.0f%%" % percent)
		
		if loader.is_loading_complete():
			var scene = loader.get_resource("res://scenes/main.tscn")
			if scene:
				loader.queue_free()
				loader = null
				get_tree().change_scene_to_packed(scene)
			else:
				push_error("[gpu_basics] Failed to load main menu scene")
				is_loading = false
				if loader:
					loader.queue_free()
					loader = null
		return
	
	# Track benchmark time
	if benchmark_running:
		benchmark_timer += delta
		
		# Update performance monitor
		if perf_monitor:
			perf_monitor.update(delta)
		
		# Collect metrics
		var fps = Engine.get_frames_per_second()
		var frame_time = delta * 1000.0
		var cpu_usage = perf_monitor.read_cpu_usage() if perf_monitor else 0.0
		var temp = perf_monitor.get_temperature() if perf_monitor else 0.0
		var gpu_usage = perf_monitor.read_gpu_usage() if perf_monitor else 0.0
		
		# Store metrics
		metrics.push_back({
			"time": benchmark_timer,
			"fps": fps,
			"frame_time": frame_time,
			"cpu": cpu_usage,
			"temp": temp,
			"gpu": gpu_usage
		})
		
		# Update UI overlay (every 3 frames to reduce overhead)
		if metrics_overlay and Engine.get_process_frames() % 3 == 0:
			metrics_overlay.update_metrics(fps, frame_time, cpu_usage, temp, gpu_usage)
			metrics_overlay.update_progress(benchmark_timer, benchmark_duration)
		
		# Check if benchmark complete
		if benchmark_timer >= benchmark_duration:
			benchmark_running = false
			_finish_benchmark()

func _finish_benchmark():
	print("\n========================================")
	print("[GPUBasics] Benchmark Complete!")
	print("========================================\n")
	
	if cpp_controller:
		cpp_controller.stop_test()
	
	# Calculate and export results
	_export_results()
	
	# Wait a moment before returning to menu
	await get_tree().create_timer(2.0).timeout
	
	print("\n[GPUBasics] Returning to main menu...")
	_load_scene_threaded("res://scenes/main.tscn")

func _export_results():
	"""Calculate statistics and export results to JSON"""
	if metrics.is_empty():
		print("[GPUBasics] No metrics to export")
		return
	
	# Calculate statistics
	var fps_data = []
	var frame_time_data = []
	var cpu_data = []
	var temp_data = []
	var gpu_data = []
	
	for sample in metrics:
		fps_data.push_back(sample["fps"])
		frame_time_data.push_back(sample["frame_time"])
		cpu_data.push_back(sample["cpu"])
		temp_data.push_back(sample["temp"])
		gpu_data.push_back(sample["gpu"])
	
	# Calculate averages
	var avg_fps = _calculate_average(fps_data)
	var avg_frame_time = _calculate_average(frame_time_data)
	var avg_cpu = _calculate_average(cpu_data)
	var avg_temp = _calculate_average(temp_data)
	var avg_gpu = _calculate_average(gpu_data)
	
	# Calculate percentiles
	var fps_percentiles = _calculate_percentiles(fps_data)
	var frame_time_percentiles = _calculate_percentiles(frame_time_data)
	
	# Calculate min/max
	var min_fps = fps_data.min()
	var max_fps = fps_data.max()
	
	# Print results
	print("Performance Summary:")
	print("-------------------")
	print("  FPS: Avg=%.1f, Min=%.1f, Max=%.1f" % [avg_fps, min_fps, max_fps])
	print("  Frame Time: Avg=%.2fms" % avg_frame_time)
	print("  CPU: Avg=%.1f%%" % avg_cpu)
	print("  GPU: Avg=%.1f%%" % avg_gpu)
	print("  Temp: Avg=%.1f°C" % avg_temp)
	print("\nPercentiles:")
	print("  FPS: P1=%.1f, P5=%.1f, P50=%.1f, P95=%.1f, P99=%.1f" % [
		fps_percentiles["p1"], fps_percentiles["p5"], fps_percentiles["p50"],
		fps_percentiles["p95"], fps_percentiles["p99"]
	])
	
	# Build results dictionary
	var results = {
		"benchmark": "gpu_basics",
		"version": "1.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"duration": benchmark_duration,
		"sample_count": metrics.size(),
		"metrics": {
			"avg_fps": avg_fps,
			"min_fps": min_fps,
			"max_fps": max_fps,
			"avg_frame_time_ms": avg_frame_time,
			"avg_cpu_usage": avg_cpu,
			"avg_gpu_usage": avg_gpu,
			"avg_temperature": avg_temp,
			"fps_percentiles": fps_percentiles,
			"frame_time_percentiles": frame_time_percentiles
		},
		"platform": {}
	}
	
	# Add platform info
	if platform_detector:
		results["platform"] = {
			"name": platform_detector.get_platform_name(),
			"cpu": platform_detector.get_cpu_name(),
			"gpu": platform_detector.get_gpu_name(),
			"ram_mb": platform_detector.get_ram_mb()
		}
	
	# Export to JSON
	var json_string = JSON.stringify(results, "\t")
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://gpu_basics_results_%s.json" % timestamp
	
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("\n✓ Results exported to: %s" % filename)
	else:
		print("\n✗ Failed to export results")

func _calculate_average(data: Array) -> float:
	"""Calculate average of array"""
	if data.is_empty():
		return 0.0
	var sum = 0.0
	for value in data:
		sum += value
	return sum / float(data.size())

func _calculate_percentiles(data: Array) -> Dictionary:
	"""Calculate percentiles (P1, P5, P50, P95, P99)"""
	if data.is_empty():
		return {"p1": 0.0, "p5": 0.0, "p50": 0.0, "p95": 0.0, "p99": 0.0}
	
	# Sort in-place for percentile calculation
	data.sort()
	
	var size = data.size()
	return {
		"p1": data[int(size * 0.01)],
		"p5": data[int(size * 0.05)],
		"p50": data[int(size * 0.50)],
		"p95": data[int(size * 0.95)],
		"p99": data[int(size * 0.99)]
	}

func _input(event):
	# Allow ESC to return to menu (but not during loading)
	if event.is_action_pressed("ui_cancel") and not is_loading:
		print("\n[gpu_basics.gd] Cancelled by user")
		if cpp_controller:
			cpp_controller.stop_test()
		_load_scene_threaded("res://scenes/main.tscn")

func _load_scene_threaded(scene_path: String):
	"""Load a scene asynchronously with loading screen"""
	if is_loading:
		return
	
	is_loading = true
	
	# Create threaded loader
	loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(loader)
	
	# Queue scene for loading
	loader.queue_resource(scene_path)
	
	# Show loading screen
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Returning to menu...")

func _exit_tree():
	if cpp_controller:
		cpp_controller.stop_test()
	print("[gpu_basics.gd] Benchmark stopped")


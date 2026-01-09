extends Node
## GodotMark Entry Point
## Editor Testing & Refinement Version

# Core systems (C++)
var platform_detector: PlatformDetector
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager

# UI references
@onready var debug_controller = $DebugController
@onready var stats_overlay = $UI/StatsOverlay

func _ready():
	print("\n========================================")
	print("[GodotMark] Initializing...")
	print("========================================\n")
	
	# Initialize C++ systems
	initialize_systems()
	
	# Check driver stack on Raspberry Pi
	if platform_detector.is_raspberry_pi():
		check_driver_stack()
	
	# Connect UI to systems
	stats_overlay.set_monitors(perf_monitor, quality_manager)
	debug_controller.set_systems(quality_manager, null)  # Will set stress_test later
	
	print("\n[main.gd] Ready! Use debug keys to control:")
	print("  Space - Pause/Resume")
	print("  Q/E   - Quality Down/Up")
	print("  T     - Toggle Quick Test (10s/60s)")
	print("  V     - Verbose Logging")
	print("  M     - Launch Model Showcase (1-minute benchmark)")
	print("  Esc   - Exit\n")

func initialize_systems():
	# Platform detection
	platform_detector = PlatformDetector.new()
	platform_detector.initialize()
	
	# Performance monitoring
	perf_monitor = PerformanceMonitor.new()
	
	# Quality management
	quality_manager = AdaptiveQualityManager.new()
	quality_manager.initialize(AdaptiveQualityManager.MEDIUM)
	
	print("[main.gd] Core systems initialized")

func _process(delta):
	# Update performance monitoring
	if perf_monitor:
		perf_monitor.update(delta)
	
	# Update adaptive quality
	if quality_manager and perf_monitor:
		var fps = perf_monitor.get_avg_fps()
		var temp = perf_monitor.get_temperature()
		quality_manager.update(fps, temp)


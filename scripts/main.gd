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

func check_driver_stack():
	"""Check if V3D/Vulkan driver stack is properly configured on Raspberry Pi"""
	
	var v3d_loaded = platform_detector.is_v3d_driver_loaded()
	var v3d_config = platform_detector.is_v3d_config_enabled()
	var vulkan_available = platform_detector.is_vulkan_driver_available()
	
	# Print detailed driver status
	print(platform_detector.get_driver_status_summary())
	
	# Show warning if not fully configured
	if not v3d_loaded or not v3d_config or not vulkan_available:
		print("\n" + "=".repeat(60))
		print("[WARNING] Suboptimal graphics driver configuration detected!")
		print("=".repeat(60))
		print("")
		print("Your Raspberry Pi may not be using the V3D driver stack.")
		print("This will result in reduced performance and benchmark accuracy.")
		print("")
		print("To fix this, run the automated installer:")
		print("  1. Exit this application")
		print("  2. Open a terminal in the godotmark directory")
		print("  3. Run: sudo ./install_v3d_stack.sh")
		print("  4. Follow the prompts and reboot if requested")
		print("")
		print("Alternatively, verify your setup with:")
		print("  ./check_v3d_setup.sh")
		print("")
		print("Continuing in 5 seconds...")
		print("=".repeat(60) + "\n")
		
		# Wait 5 seconds before continuing
		await get_tree().create_timer(5.0).timeout
	else:
		print("\n[OK] V3D driver stack properly configured!\n")

func _process(delta):
	# Update performance monitoring
	if perf_monitor:
		perf_monitor.update(delta)
	
	# Update adaptive quality
	if quality_manager and perf_monitor:
		var fps = perf_monitor.get_avg_fps()
		var temp = perf_monitor.get_temperature()
		quality_manager.update(fps, temp)


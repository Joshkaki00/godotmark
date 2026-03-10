extends Node
## GodotMark Entry Point
## Main menu launcher with CLI support

# Core systems (C++)
var platform_detector: PlatformDetector
var perf_monitor: PerformanceMonitor
var quality_manager: AdaptiveQualityManager

# CLI handler
var cli: CLI

func _ready():
	# Parse CLI arguments first
	cli = CLI.new()
	var options = cli.parse_args()
	
	# Handle --help
	if cli.should_show_help():
		CLI.print_help()
		get_tree().quit(0)
		return
	
	# Handle --version
	if cli.should_show_version():
		Version.print_version_info()
		get_tree().quit(0)
		return
	
	# Validate CLI options
	if not cli.validate_options():
		get_tree().quit(1)
		return
	
	print("\n========================================")
	print("[GodotMark] Initializing...")
	print("========================================\n")
	
	# Print version information
	Version.print_version_info()
	print("")
	
	# Show CLI options if verbose
	if options.verbose:
		print("[CLI] Options parsed:")
		for key in options:
			if options[key]:
				print("  %s: %s" % [key, options[key]])
		print("")
	
	# Load and apply settings first
	load_and_apply_settings()
	
	# Initialize C++ systems
	initialize_systems()
	
	# Apply CLI quality override
	var quality_preset = cli.get_quality_preset()
	if quality_preset != "medium":
		apply_quality_from_cli(quality_preset)
	
	# Check driver stack on Raspberry Pi
	if platform_detector.is_raspberry_pi():
		check_driver_stack()
	
	# Handle CLI benchmark execution
	if options.run_benchmarks or options.quick_test or options.benchmark != "":
		handle_cli_benchmark()
	elif options.skip_intro:
		# Skip splash, go straight to menu
		print("\n[main.gd] Skipping intro, loading menu...\n")
	else:
		print("\n[main.gd] Ready! Main menu loaded.\n")

func load_and_apply_settings():
	"""Load settings from config file and apply them"""
	SettingsManager.load_settings()
	SettingsManager.apply_all_settings()
	print("[main.gd] Settings loaded and applied")

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

func get_platform_info() -> String:
	"""Get platform info string for display"""
	if platform_detector:
		var cpu_model = platform_detector.get_cpu_model()
		if platform_detector.is_raspberry_pi():
			return "Raspberry Pi"
		elif cpu_model != "Unknown CPU" and cpu_model != "":
			return cpu_model
	return "Unknown Platform"

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

func apply_quality_from_cli(preset: String):
	"""Apply quality preset from CLI argument"""
	var preset_map = {
		"low": AdaptiveQualityManager.LOW,
		"medium": AdaptiveQualityManager.MEDIUM,
		"high": AdaptiveQualityManager.HIGH,
		"ultra": AdaptiveQualityManager.ULTRA
	}
	
	if preset in preset_map:
		quality_manager.set_quality_preset(preset_map[preset])
		print("[CLI] Quality preset set to: %s" % preset)

func handle_cli_benchmark():
	"""Handle CLI benchmark execution"""
	var options = cli.options
	
	print("\n========================================")
	print("[CLI] Running benchmarks in headless mode")
	print("========================================\n")
	
	if options.quick_test:
		print("[CLI] Quick test mode (10 seconds)")
		# TODO: Implement quick test
		get_tree().quit(0)
	elif options.benchmark != "":
		print("[CLI] Running benchmark: %s" % options.benchmark)
		run_specific_benchmark(options.benchmark)
	elif options.run_benchmarks:
		print("[CLI] Running all benchmarks")
		run_all_benchmarks()

func run_specific_benchmark(benchmark_name: String):
	"""Run a specific benchmark and export results"""
	var scene_map = {
		"model-showcase": "res://scenes/model_showcase.tscn",
		"nature-island": "res://scenes/nature_island.tscn"
	}
	
	if benchmark_name in scene_map:
		# Change to benchmark scene
		# The benchmark will handle results export using cli.get_output_path()
		get_tree().change_scene_to_file(scene_map[benchmark_name])
	else:
		CLI.print_error("Unknown benchmark: " + benchmark_name)
		get_tree().quit(1)

func run_all_benchmarks():
	"""Run all benchmarks in sequence"""
	# TODO: Implement sequential benchmark runner
	print("[CLI] Sequential benchmark runner not yet implemented")
	print("[CLI] Use --benchmark to run specific benchmarks")
	get_tree().quit(0)

func get_cli_output_path(benchmark_name: String = "") -> String:
	"""Get output path for benchmark results (called by benchmark scripts)"""
	if not cli:
		return "user://benchmark_results_%d.json" % Time.get_ticks_msec()
	
	var base_path = cli.get_output_path()
	
	# If benchmark name provided and path doesn't already include it, insert it
	if benchmark_name != "" and not base_path.contains(benchmark_name):
		var ext = base_path.get_extension()
		var without_ext = base_path.get_basename()
		return "%s_%s.%s" % [without_ext, benchmark_name, ext]
	
	return base_path

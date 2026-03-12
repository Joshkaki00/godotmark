extends RefCounted
## Command Line Interface Handler for GodotMark
## Parses and processes CLI arguments

class_name CLI

## Parsed CLI options
var options = {
	"help": false,
	"run_benchmarks": false,
	"quick_test": false,
	"benchmark": "",  # Specific benchmark to run (model-showcase, nature-island)
	"output_path": "",  # Custom output path for results JSON
	"quality": "",  # Quality preset (low, medium, high, ultra)
	"skip_intro": false,  # Skip splash screen
	"verbose": false,  # Verbose logging
	"version": false  # Show version and exit
}

## Parse command line arguments
func parse_args() -> Dictionary:
	var args = OS.get_cmdline_user_args()
	
	for i in range(args.size()):
		var arg = args[i]
		
		match arg:
			"--help", "-h":
				options.help = true
			
			"--version", "-v":
				options.version = true
			
			"--run-benchmarks":
				options.run_benchmarks = true
			
			"--quick-test":
				options.quick_test = true
			
			"--benchmark", "-b":
				if i + 1 < args.size():
					options.benchmark = args[i + 1]
			
			"--output-path", "-o":
				if i + 1 < args.size():
					options.output_path = args[i + 1]
			
			"--quality", "-q":
				if i + 1 < args.size():
					options.quality = args[i + 1].to_lower()
			
			"--skip-intro":
				options.skip_intro = true
			
			"--verbose":
				options.verbose = true
	
	return options

## Print help message
static func print_help():
	print("""
╔════════════════════════════════════════════════════════════════════════════╗
║                        GodotMark Command Line Interface                    ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
  godotmark [OPTIONS]

OPTIONS:
  -h, --help              Show this help message and exit
  -v, --version           Show version information and exit
  
BENCHMARK CONTROL:
  --run-benchmarks        Run all benchmarks automatically (no menu)
  --quick-test            Run quick 10-second test (for CI/testing)
  -b, --benchmark NAME    Run specific benchmark:
                            model-showcase  - GPU stress test
                            nature-island   - Draw call efficiency test
  
OUTPUT:
  -o, --output-path PATH  Save results JSON to custom path
                          Default: user://benchmark_results_<timestamp>.json
                          Example: --output-path /home/pi/results/test.json
  
QUALITY:
  -q, --quality PRESET    Set quality preset:
                            low     - Minimum quality (best performance)
                            medium  - Balanced (default)
                            high    - High quality
                            ultra   - Maximum quality (slowest)
  
MISC:
  --skip-intro            Skip splash screen and go straight to menu
  --verbose               Enable verbose logging (for debugging)

EXAMPLES:
  # Show help
  godotmark --help
  
  # Run all benchmarks with custom output
  godotmark --run-benchmarks --output-path ./my_results.json
  
  # Run specific benchmark on low quality
  godotmark --benchmark nature-island --quality low
  
  # Quick test for CI/automation
  godotmark --quick-test --skip-intro
  
  # Verbose output for debugging
  godotmark --verbose

ENVIRONMENT VARIABLES:
  GODOTMARK_OUTPUT_DIR    Default directory for benchmark results
  GODOTMARK_QUALITY       Default quality preset (low/medium/high/ultra)

FILES:
  user://benchmark_results_*.json      Benchmark results (JSON format)
  user://godotmark_settings.cfg        User settings
  user://logs/godotmark_*.log          Debug logs

SUPPORTED PLATFORMS:
  - Raspberry Pi 4 / 5
  - Orange Pi 5
  - Rock 5B
  - x86_64 Linux / Windows (for development)

DOCUMENTATION:
  README.md               Project overview
  CHANGELOG.md            Complete project history
  BUILD_AND_RUN.md        Build instructions
  TESTING_GUIDE.md        Testing procedures

COMMUNITY:
  GitHub: https://github.com/yourusername/godotmark
  Issues: https://github.com/yourusername/godotmark/issues

╔════════════════════════════════════════════════════════════════════════════╗
║  GodotMark v0.1.0-alpha - 3D Gaming Benchmark for ARM Single-Board Computers
║  Licensed under MIT - See LICENSE file for details
╚════════════════════════════════════════════════════════════════════════════╝
""")

## Validate options
func validate_options() -> bool:
	# Check if benchmark name is valid
	if options.benchmark != "":
		var valid_benchmarks = ["model-showcase", "nature-island"]
		if not options.benchmark in valid_benchmarks:
			print_error("Invalid benchmark name: " + options.benchmark)
			print_error("Valid options: " + ", ".join(valid_benchmarks))
			return false
	
	# Check if quality preset is valid
	if options.quality != "":
		var valid_quality = ["low", "medium", "high", "ultra"]
		if not options.quality in valid_quality:
			print_error("Invalid quality preset: " + options.quality)
			print_error("Valid options: " + ", ".join(valid_quality))
			return false
	
	# Check if output path is writable (if specified)
	if options.output_path != "":
		var dir_path = options.output_path.get_base_dir()
		if dir_path != "" and not DirAccess.dir_exists_absolute(dir_path):
			print_error("Output directory does not exist: " + dir_path)
			return false
	
	return true

## Print error message
static func print_error(message: String):
	print("\n[ERROR] " + message + "\n")
	print("Run 'godotmark --help' for usage information.\n")

## Check if should show help
func should_show_help() -> bool:
	return options.help

## Check if should show version
func should_show_version() -> bool:
	return options.version

## Get output path (with fallback to default)
func get_output_path() -> String:
	if options.output_path != "":
		return options.output_path
	
	# Check environment variable
	var env_dir = OS.get_environment("GODOTMARK_OUTPUT_DIR")
	if env_dir != "":
		var timestamp = Time.get_unix_time_from_system()
		return env_dir.path_join("benchmark_results_%d.json" % timestamp)
	
	# Default
	var timestamp = Time.get_unix_time_from_system()
	return "user://benchmark_results_%d.json" % timestamp

## Get quality preset
func get_quality_preset() -> String:
	if options.quality != "":
		return options.quality
	
	# Check environment variable
	var env_quality = OS.get_environment("GODOTMARK_QUALITY")
	if env_quality != "":
		return env_quality.to_lower()
	
	# Default
	return "medium"

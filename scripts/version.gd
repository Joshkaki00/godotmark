extends Node
## Version Information
## Semantic versioning: MAJOR.MINOR.PATCH-PRERELEASE
## See: https://semver.org/

# Version components
const MAJOR = 0
const MINOR = 0
const PATCH = 1
const PRERELEASE = "alpha"

# Full version string
const VERSION = "0.0.1-alpha"

# Version status explanation
const STATUS_DESCRIPTION = "Early alpha - core features in active development"

# Build information (can be set by build scripts)
var build_number: String = "dev"
var build_date: String = ""

func _ready():
	# Get build date from system if not set by build script
	if build_date.is_empty():
		var datetime = Time.get_datetime_dict_from_system()
		build_date = "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day]

func get_version_string() -> String:
	"""Get the full version string"""
	return VERSION

func get_version_with_build() -> String:
	"""Get version string with build information"""
	return "%s (build %s, %s)" % [VERSION, build_number, build_date]

func get_short_version() -> String:
	"""Get short version without prerelease tag"""
	return "%d.%d.%d" % [MAJOR, MINOR, PATCH]

func is_alpha() -> bool:
	"""Check if this is an alpha release"""
	return PRERELEASE == "alpha"

func is_beta() -> bool:
	"""Check if this is a beta release"""
	return PRERELEASE == "beta"

func is_release_candidate() -> bool:
	"""Check if this is a release candidate"""
	return PRERELEASE.begins_with("rc")

func is_stable() -> bool:
	"""Check if this is a stable release (no prerelease tag)"""
	return PRERELEASE.is_empty()

func print_version_info():
	"""Print version information to console"""
	print("========================================")
	print("GodotMark Version: %s" % VERSION)
	print("Status: %s" % STATUS_DESCRIPTION)
	print("Build: %s (%s)" % [build_number, build_date])
	print("========================================")

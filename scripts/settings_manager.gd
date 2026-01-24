extends Node
## Settings Manager Singleton
## Manages all application settings with persistence to config file

# Signals for settings changes
signal settings_changed
signal graphics_settings_changed
signal audio_settings_changed
signal benchmark_settings_changed

# Config file
var config_file: ConfigFile
const CONFIG_PATH = "user://settings.cfg"

# Graphics settings
var resolution_x: int = 1280
var resolution_y: int = 720
var fullscreen: bool = false
var vsync: bool = true
var rendering_method: String = "mobile"
var shadow_quality: int = 2  # 0=Low, 1=Medium, 2=High, 3=Ultra

# Benchmark settings
var benchmark_duration: int = 60  # seconds
var quality_preset: int = 2  # 0=Low, 1=Medium, 2=High, 3=Ultra
var adaptive_quality: bool = true

# Audio settings
var master_volume: int = 100  # 0-100
var music_volume: int = 80  # 0-100
var sfx_volume: int = 100  # 0-100
var muted: bool = false

# Available resolutions
var available_resolutions = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

func _ready():
	config_file = ConfigFile.new()
	load_settings()
	print("[SettingsManager] Initialized")

func load_settings():
	"""Load settings from config file or use defaults"""
	var err = config_file.load(CONFIG_PATH)
	
	if err != OK:
		print("[SettingsManager] No config file found, using defaults")
		save_settings()  # Create default config file
		return
	
	# Load graphics settings
	resolution_x = config_file.get_value("graphics", "resolution_x", 1280)
	resolution_y = config_file.get_value("graphics", "resolution_y", 720)
	fullscreen = config_file.get_value("graphics", "fullscreen", false)
	vsync = config_file.get_value("graphics", "vsync", true)
	rendering_method = config_file.get_value("graphics", "rendering_method", "mobile")
	shadow_quality = config_file.get_value("graphics", "shadow_quality", 2)
	
	# Load benchmark settings
	benchmark_duration = config_file.get_value("benchmark", "duration", 60)
	quality_preset = config_file.get_value("benchmark", "quality_preset", 2)
	adaptive_quality = config_file.get_value("benchmark", "adaptive_quality", true)
	
	# Load audio settings
	master_volume = config_file.get_value("audio", "master_volume", 100)
	music_volume = config_file.get_value("audio", "music_volume", 80)
	sfx_volume = config_file.get_value("audio", "sfx_volume", 100)
	muted = config_file.get_value("audio", "muted", false)
	
	print("[SettingsManager] Settings loaded from %s" % CONFIG_PATH)

func save_settings():
	"""Save all settings to config file"""
	# Save graphics settings
	config_file.set_value("graphics", "resolution_x", resolution_x)
	config_file.set_value("graphics", "resolution_y", resolution_y)
	config_file.set_value("graphics", "fullscreen", fullscreen)
	config_file.set_value("graphics", "vsync", vsync)
	config_file.set_value("graphics", "rendering_method", rendering_method)
	config_file.set_value("graphics", "shadow_quality", shadow_quality)
	
	# Save benchmark settings
	config_file.set_value("benchmark", "duration", benchmark_duration)
	config_file.set_value("benchmark", "quality_preset", quality_preset)
	config_file.set_value("benchmark", "adaptive_quality", adaptive_quality)
	
	# Save audio settings
	config_file.set_value("audio", "master_volume", master_volume)
	config_file.set_value("audio", "music_volume", music_volume)
	config_file.set_value("audio", "sfx_volume", sfx_volume)
	config_file.set_value("audio", "muted", muted)
	
	var err = config_file.save(CONFIG_PATH)
	if err == OK:
		print("[SettingsManager] Settings saved to %s" % CONFIG_PATH)
	else:
		push_error("[SettingsManager] Failed to save settings: %s" % err)
	
	settings_changed.emit()

func apply_all_settings():
	"""Apply all settings to the engine"""
	apply_graphics_settings()
	apply_audio_settings()
	print("[SettingsManager] All settings applied")

func apply_graphics_settings():
	"""Apply graphics settings to the engine"""
	# Set window size and mode
	DisplayServer.window_set_size(Vector2i(resolution_x, resolution_y))
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Set VSync
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Note: Rendering method requires restart, handled in UI
	
	graphics_settings_changed.emit()
	print("[SettingsManager] Graphics settings applied")

func apply_audio_settings():
	"""Apply audio settings to AudioServer"""
	# Get bus indices
	var master_bus_idx = AudioServer.get_bus_index("Master")
	
	if muted:
		AudioServer.set_bus_mute(master_bus_idx, true)
	else:
		AudioServer.set_bus_mute(master_bus_idx, false)
		
		# Set master volume
		var master_db = linear_to_db(master_volume / 100.0)
		AudioServer.set_bus_volume_db(master_bus_idx, master_db)
		
		# Note: Music and SFX buses would need to be created in project
		# For now we just store the values
	
	audio_settings_changed.emit()
	print("[SettingsManager] Audio settings applied")

func reset_to_defaults():
	"""Reset all settings to default values"""
	# Graphics defaults
	resolution_x = 1280
	resolution_y = 720
	fullscreen = false
	vsync = true
	rendering_method = "mobile"
	shadow_quality = 2
	
	# Benchmark defaults
	benchmark_duration = 60
	quality_preset = 2
	adaptive_quality = true
	
	# Audio defaults
	master_volume = 100
	music_volume = 80
	sfx_volume = 100
	muted = false
	
	save_settings()
	apply_all_settings()
	print("[SettingsManager] Reset to defaults")

# Getters for resolution as string
func get_resolution_string() -> String:
	return "%dx%d" % [resolution_x, resolution_y]

func get_quality_preset_name() -> String:
	match quality_preset:
		0: return "Low"
		1: return "Medium"
		2: return "High"
		3: return "Ultra"
		_: return "Unknown"

func get_shadow_quality_name() -> String:
	match shadow_quality:
		0: return "Low"
		1: return "Medium"
		2: return "High"
		3: return "Ultra"
		_: return "Unknown"

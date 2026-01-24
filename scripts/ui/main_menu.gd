extends Control
## Main Menu Controller
## Provides access to all benchmark tests

# UI references
@onready var subtitle = $CenterContainer/VBoxContainer/Subtitle
@onready var model_showcase_button = $CenterContainer/VBoxContainer/ModelShowcaseButton
@onready var full_suite_button = $CenterContainer/VBoxContainer/FullSuiteButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var exit_button = $CenterContainer/VBoxContainer/ExitButton
@onready var loading_screen = $LoadingScreen

# Threaded loading state
var is_loading = false
var loader = null
var target_scene_path = ""

func _ready():
	# Update subtitle with system info
	update_system_info()
	
	# Connect button signals
	model_showcase_button.pressed.connect(_on_model_showcase_pressed)
	full_suite_button.pressed.connect(_on_full_suite_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Connect hover sounds for all active buttons
	model_showcase_button.mouse_entered.connect(_on_button_hover)
	settings_button.mouse_entered.connect(_on_button_hover)
	exit_button.mouse_entered.connect(_on_button_hover)
	
	print("\n[MainMenu] Ready - Select a benchmark to begin")

func update_system_info():
	# Try to get platform info from Main scene if available
	var main = get_tree().root.get_node_or_null("Main")
	if main and main.has_method("get_platform_info"):
		var info = main.get_platform_info()
		subtitle.text = "v%s | %s" % [Version.get_version_string(), info]
	else:
		# Fallback: create temporary detector
		var platform_detector = PlatformDetector.new()
		platform_detector.initialize()
		
		var cpu_model = platform_detector.get_cpu_model()
		var is_rpi = platform_detector.is_raspberry_pi()
		
		if is_rpi:
			subtitle.text = "v%s | Raspberry Pi" % Version.get_version_string()
		elif cpu_model != "Unknown CPU" and cpu_model != "":
			subtitle.text = "v%s | %s" % [Version.get_version_string(), cpu_model]
		else:
			subtitle.text = "v%s" % Version.get_version_string()
		
		# Note: PlatformDetector is RefCounted, so it's automatically freed

func _on_button_hover():
	"""Play hover sound when mouse enters a button"""
	UIAudioManager.play_hover()

func _on_model_showcase_pressed():
	UIAudioManager.play_confirm()
	print("[MainMenu] Launching Model Showcase...")
	load_scene_threaded("res://scenes/model_showcase.tscn")

func _on_full_suite_pressed():
	UIAudioManager.play_error()  # Error sound since it's disabled
	# Currently disabled - reserved for future implementation
	print("[MainMenu] Full Suite not yet implemented")

func _on_settings_pressed():
	UIAudioManager.play_confirm()
	print("[MainMenu] Opening Settings...")
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_exit_pressed():
	UIAudioManager.play_back()
	print("[MainMenu] Exiting...")
	get_tree().quit()

func load_scene_threaded(scene_path: String):
	"""Load a scene asynchronously with loading screen"""
	if is_loading:
		return
	
	is_loading = true
	target_scene_path = scene_path
	
	# Create threaded loader
	loader = preload("res://scripts/utils/threaded_loader.gd").new()
	add_child(loader)
	
	# Queue scene for loading
	loader.queue_resource(scene_path)
	
	# Show loading screen
	if loading_screen:
		loading_screen.visible = true
		loading_screen.update_progress(0.0, "Loading benchmark...")
	
	# Disable buttons during loading
	model_showcase_button.disabled = true
	settings_button.disabled = true
	exit_button.disabled = true

func _process(_delta):
	"""Update loading progress"""
	if not is_loading or not loader:
		return
	
	# Update loader progress
	loader.update_progress()
	
	# Get progress
	var progress = loader.get_overall_progress()
	var percent = progress * 100.0
	
	# Update loading screen
	if loading_screen:
		loading_screen.update_progress(percent, "Loading benchmark... %.0f%%" % percent)
	
	# Check if loading is complete
	if loader.is_loading_complete():
		var scene = loader.get_resource(target_scene_path)
		
		if scene:
			print("[MainMenu] Scene loaded successfully, transitioning...")
			# Cleanup loader
			loader.queue_free()
			loader = null
			
			# Change to loaded scene
			get_tree().change_scene_to_packed(scene)
		else:
			push_error("[MainMenu] Failed to load scene: %s" % target_scene_path)
			# Reset state
			is_loading = false
			if loading_screen:
				loading_screen.visible = false
			model_showcase_button.disabled = false
			settings_button.disabled = false
			exit_button.disabled = false
			if loader:
				loader.queue_free()
				loader = null

func _input(event):
	# Allow Escape to quit from main menu (but not during loading)
	if event.is_action_pressed("ui_cancel") and not is_loading:
		_on_exit_pressed()


extends Control
## Settings Menu Controller
## Manages UI for all settings categories

# Graphics UI references
@onready var resolution_option = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/ResolutionOption
@onready var fullscreen_check = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/FullscreenCheck
@onready var vsync_check = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/VsyncCheck
@onready var rendering_method_option = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/RenderingMethodOption
@onready var shadow_quality_label = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/ShadowQualityLabel
@onready var shadow_quality_slider = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Graphics/ScrollContainer/VBoxContainer/ShadowQualitySlider

# Benchmark UI references
@onready var duration_label = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Benchmark/ScrollContainer/VBoxContainer/DurationLabel
@onready var duration_slider = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Benchmark/ScrollContainer/VBoxContainer/DurationSlider
@onready var quality_preset_option = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Benchmark/ScrollContainer/VBoxContainer/QualityPresetOption
@onready var adaptive_quality_check = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Benchmark/ScrollContainer/VBoxContainer/AdaptiveQualityCheck

# Audio UI references
@onready var master_volume_label = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolumeLabel
@onready var master_volume_slider = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolumeSlider
@onready var music_volume_label = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MusicVolumeLabel
@onready var music_volume_slider = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_volume_label = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/SFXVolumeLabel
@onready var sfx_volume_slider = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/SFXVolumeSlider
@onready var mute_check = $CenterContainer/MainPanel/VBoxContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/MuteCheck

# Button references
@onready var back_button = $CenterContainer/MainPanel/VBoxContainer/ButtonsContainer/BackButton
@onready var reset_button = $CenterContainer/MainPanel/VBoxContainer/ButtonsContainer/ResetButton
@onready var apply_button = $CenterContainer/MainPanel/VBoxContainer/ButtonsContainer/ApplyButton

# Tab container for tab change sounds
@onready var tab_container = $CenterContainer/MainPanel/VBoxContainer/TabContainer

func _ready():
	# Populate resolution options
	for res in SettingsManager.available_resolutions:
		resolution_option.add_item("%dx%d" % [res.x, res.y])
	
	# Populate rendering method options
	rendering_method_option.add_item("Mobile")
	rendering_method_option.add_item("Forward+")
	
	# Populate quality preset options
	quality_preset_option.add_item("Low")
	quality_preset_option.add_item("Medium")
	quality_preset_option.add_item("High")
	quality_preset_option.add_item("Ultra")
	
	# Load current settings
	load_current_settings()
	
	# Connect signals
	connect_signals()
	
	# Connect hover sounds for buttons
	back_button.mouse_entered.connect(_on_button_hover)
	reset_button.mouse_entered.connect(_on_button_hover)
	apply_button.mouse_entered.connect(_on_button_hover)
	
	# Connect tab change sound
	tab_container.tab_changed.connect(_on_tab_changed)
	
	print("[SettingsMenu] Ready")

func connect_signals():
	"""Connect all UI signals"""
	# Graphics signals
	shadow_quality_slider.value_changed.connect(_on_shadow_quality_changed)
	
	# Benchmark signals
	duration_slider.value_changed.connect(_on_duration_changed)
	
	# Audio signals
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Button signals
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	apply_button.pressed.connect(_on_apply_pressed)

func _on_button_hover():
	"""Play hover sound when mouse enters a button"""
	UIAudioManager.play_hover()

func _on_tab_changed(_tab: int):
	"""Play sound when switching tabs"""
	UIAudioManager.play_select()

func load_current_settings():
	"""Load current settings from SettingsManager and populate UI"""
	# Graphics settings
	var current_res = Vector2i(SettingsManager.resolution_x, SettingsManager.resolution_y)
	for i in range(SettingsManager.available_resolutions.size()):
		if SettingsManager.available_resolutions[i] == current_res:
			resolution_option.selected = i
			break
	
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	vsync_check.button_pressed = SettingsManager.vsync
	
	if SettingsManager.rendering_method == "mobile":
		rendering_method_option.selected = 0
	else:
		rendering_method_option.selected = 1
	
	shadow_quality_slider.value = SettingsManager.shadow_quality
	update_shadow_quality_label(SettingsManager.shadow_quality)
	
	# Benchmark settings
	duration_slider.value = SettingsManager.benchmark_duration
	update_duration_label(SettingsManager.benchmark_duration)
	
	quality_preset_option.selected = SettingsManager.quality_preset
	adaptive_quality_check.button_pressed = SettingsManager.adaptive_quality
	
	# Audio settings
	master_volume_slider.value = SettingsManager.master_volume
	update_master_volume_label(SettingsManager.master_volume)
	
	music_volume_slider.value = SettingsManager.music_volume
	update_music_volume_label(SettingsManager.music_volume)
	
	sfx_volume_slider.value = SettingsManager.sfx_volume
	update_sfx_volume_label(SettingsManager.sfx_volume)
	
	mute_check.button_pressed = SettingsManager.muted

func save_ui_to_settings():
	"""Save UI values to SettingsManager (but don't apply yet)"""
	# Graphics settings
	var selected_res = SettingsManager.available_resolutions[resolution_option.selected]
	SettingsManager.resolution_x = selected_res.x
	SettingsManager.resolution_y = selected_res.y
	SettingsManager.fullscreen = fullscreen_check.button_pressed
	SettingsManager.vsync = vsync_check.button_pressed
	
	if rendering_method_option.selected == 0:
		SettingsManager.rendering_method = "mobile"
	else:
		SettingsManager.rendering_method = "forward_plus"
	
	SettingsManager.shadow_quality = int(shadow_quality_slider.value)
	
	# Benchmark settings
	SettingsManager.benchmark_duration = int(duration_slider.value)
	SettingsManager.quality_preset = quality_preset_option.selected
	SettingsManager.adaptive_quality = adaptive_quality_check.button_pressed
	
	# Audio settings
	SettingsManager.master_volume = int(master_volume_slider.value)
	SettingsManager.music_volume = int(music_volume_slider.value)
	SettingsManager.sfx_volume = int(sfx_volume_slider.value)
	SettingsManager.muted = mute_check.button_pressed

# Update label callbacks
func _on_shadow_quality_changed(value: float):
	update_shadow_quality_label(int(value))

func update_shadow_quality_label(quality: int):
	var quality_name = ""
	match quality:
		0: quality_name = "Low"
		1: quality_name = "Medium"
		2: quality_name = "High"
		3: quality_name = "Ultra"
	shadow_quality_label.text = "Shadow Quality: %s" % quality_name

func _on_duration_changed(value: float):
	update_duration_label(int(value))

func update_duration_label(duration: int):
	duration_label.text = "Test Duration: %d seconds" % duration

func _on_master_volume_changed(value: float):
	update_master_volume_label(int(value))

func update_master_volume_label(volume: int):
	master_volume_label.text = "Master Volume: %d%%" % volume

func _on_music_volume_changed(value: float):
	update_music_volume_label(int(value))

func update_music_volume_label(volume: int):
	music_volume_label.text = "Music Volume: %d%%" % volume

func _on_sfx_volume_changed(value: float):
	update_sfx_volume_label(int(value))

func update_sfx_volume_label(volume: int):
	sfx_volume_label.text = "SFX Volume: %d%%" % volume

# Button handlers
func _on_apply_pressed():
	UIAudioManager.play_confirm()
	print("[SettingsMenu] Applying settings...")
	save_ui_to_settings()
	SettingsManager.save_settings()
	SettingsManager.apply_all_settings()
	
	# Check if rendering method changed
	var current_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	if current_method != SettingsManager.rendering_method:
		# Show warning that restart is required
		print("[SettingsMenu] Warning: Rendering method change requires restart")
		# Could add a popup dialog here in the future

func _on_reset_pressed():
	UIAudioManager.play_click()
	print("[SettingsMenu] Resetting to defaults...")
	SettingsManager.reset_to_defaults()
	load_current_settings()

func _on_back_pressed():
	UIAudioManager.play_back()
	print("[SettingsMenu] Returning to main menu...")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _input(event):
	# Allow Escape to return to main menu
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

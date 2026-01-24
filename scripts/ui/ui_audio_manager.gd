extends Node
## UI Audio Manager Singleton
## Manages all UI sound effects with volume control integration

# Audio players for different sound types
var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var confirm_player: AudioStreamPlayer
var back_player: AudioStreamPlayer
var error_player: AudioStreamPlayer

# Audio streams
var hover_sound: AudioStream
var click_sound: AudioStream
var confirm_sound: AudioStream
var back_sound: AudioStream
var error_sound: AudioStream

func _ready():
	# Load all audio streams
	hover_sound = load("res://art/sounds/ui/ui select.ogg")
	click_sound = load("res://art/sounds/ui/simple_ui_click_sound.ogg")
	confirm_sound = load("res://art/sounds/ui/ui confirm.ogg")
	back_sound = load("res://art/sounds/ui/ui return.ogg")
	error_sound = load("res://art/sounds/ui/343019__zenithinfinitivestudios__ui_wrong_button4.ogg")
	
	# Create audio players
	hover_player = _create_player(hover_sound)
	click_player = _create_player(click_sound)
	confirm_player = _create_player(confirm_sound)
	back_player = _create_player(back_sound)
	error_player = _create_player(error_sound)
	
	# Connect to settings changes
	if SettingsManager:
		SettingsManager.audio_settings_changed.connect(_on_audio_settings_changed)
	
	# Apply initial volume
	_update_volumes()
	
	print("[UIAudioManager] Initialized with all UI sounds")

func _create_player(stream: AudioStream) -> AudioStreamPlayer:
	"""Create and configure an audio player"""
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	return player

func _update_volumes():
	"""Update all player volumes based on settings"""
	if not SettingsManager:
		return
	
	var volume_db = _calculate_volume_db()
	
	if hover_player:
		hover_player.volume_db = volume_db
	if click_player:
		click_player.volume_db = volume_db
	if confirm_player:
		confirm_player.volume_db = volume_db
	if back_player:
		back_player.volume_db = volume_db
	if error_player:
		error_player.volume_db = volume_db

func _calculate_volume_db() -> float:
	"""Calculate volume in dB based on settings"""
	if SettingsManager.muted:
		return -80.0  # Effectively silent
	
	# Combine master and SFX volumes (0-100 range)
	var master = SettingsManager.master_volume / 100.0
	var sfx = SettingsManager.sfx_volume / 100.0
	var combined = master * sfx
	
	# Convert to decibels (range: -80 to 0 dB)
	if combined <= 0.0:
		return -80.0
	
	return linear_to_db(combined)

func _on_audio_settings_changed():
	"""Called when audio settings change"""
	_update_volumes()

# Public API for playing sounds

func play_hover():
	"""Play hover/selection sound"""
	if hover_player and not hover_player.playing:
		hover_player.play()

func play_click():
	"""Play general click sound"""
	if click_player:
		click_player.play()

func play_confirm():
	"""Play confirmation/accept sound"""
	if confirm_player:
		confirm_player.play()

func play_back():
	"""Play back/cancel sound"""
	if back_player:
		back_player.play()

func play_error():
	"""Play error/invalid action sound"""
	if error_player:
		error_player.play()

func play_select():
	"""Alias for play_click - used for list/dropdown selections"""
	play_click()

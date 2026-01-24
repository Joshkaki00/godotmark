extends Node
## UI Audio Manager Singleton
## Manages all UI sound effects with volume control integration and sound pooling

# Audio streams (preloaded for instant playback)
var hover_sound: AudioStream
var click_sound: AudioStream
var confirm_sound: AudioStream
var back_sound: AudioStream
var error_sound: AudioStream

# Sound pools - multiple players per sound type for overlapping sounds
var hover_pool: Array[AudioStreamPlayer] = []
var click_pool: Array[AudioStreamPlayer] = []
var confirm_pool: Array[AudioStreamPlayer] = []
var back_pool: Array[AudioStreamPlayer] = []
var error_pool: Array[AudioStreamPlayer] = []

# Pool size per sound type
const POOL_SIZE = 3  # Allow up to 3 overlapping sounds per type

# Last hover play time to prevent spam
var last_hover_time: float = 0.0
const HOVER_COOLDOWN: float = 0.05  # 50ms cooldown between hovers

func _ready():
	# Load all audio streams
	hover_sound = load("res://art/sounds/ui/ui select.ogg")
	click_sound = load("res://art/sounds/ui/simple_ui_click_sound.ogg")
	confirm_sound = load("res://art/sounds/ui/ui confirm.ogg")
	back_sound = load("res://art/sounds/ui/ui return.ogg")
	error_sound = load("res://art/sounds/ui/343019__zenithinfinitivestudios__ui_wrong_button4.ogg")
	
	# Create player pools for each sound type
	_create_pool(hover_pool, hover_sound)
	_create_pool(click_pool, click_sound)
	_create_pool(confirm_pool, confirm_sound)
	_create_pool(back_pool, back_sound)
	_create_pool(error_pool, error_sound)
	
	# Connect to settings changes
	if SettingsManager:
		SettingsManager.audio_settings_changed.connect(_on_audio_settings_changed)
	
	# Apply initial volume
	_update_volumes()
	
	print("[UIAudioManager] Initialized with pooled UI sounds (pool size: %d per type)" % POOL_SIZE)

func _create_pool(pool: Array[AudioStreamPlayer], stream: AudioStream):
	"""Create a pool of players for a sound type"""
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.stream = stream
		player.bus = "Master"
		player.max_polyphony = 1  # Prevent individual player overlap
		add_child(player)
		pool.append(player)

func _update_volumes():
	"""Update all player volumes based on settings"""
	if not SettingsManager:
		return
	
	var volume_db = _calculate_volume_db()
	
	# Update all players in all pools
	for player in hover_pool:
		player.volume_db = volume_db
	for player in click_pool:
		player.volume_db = volume_db
	for player in confirm_pool:
		player.volume_db = volume_db
	for player in back_pool:
		player.volume_db = volume_db
	for player in error_pool:
		player.volume_db = volume_db

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

func _get_available_player(pool: Array[AudioStreamPlayer]) -> AudioStreamPlayer:
	"""Get an available player from the pool (or reuse the oldest)"""
	# First pass: find a player that's not playing
	for player in pool:
		if not player.playing:
			return player
	
	# Second pass: all are playing, stop and reuse the first one
	# This ensures EVERY action plays, even if it interrupts an older sound
	var player = pool[0]
	player.stop()
	return player

func play_hover():
	"""Play hover/selection sound with cooldown to prevent spam"""
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Cooldown check to prevent hover spam
	if current_time - last_hover_time < HOVER_COOLDOWN:
		return
	
	last_hover_time = current_time
	var player = _get_available_player(hover_pool)
	player.play()

func play_click():
	"""Play general click sound - always plays immediately"""
	var player = _get_available_player(click_pool)
	player.play()

func play_confirm():
	"""Play confirmation/accept sound - always plays immediately"""
	var player = _get_available_player(confirm_pool)
	player.play()

func play_back():
	"""Play back/cancel sound - always plays immediately"""
	var player = _get_available_player(back_pool)
	player.play()

func play_error():
	"""Play error/invalid action sound - always plays immediately"""
	var player = _get_available_player(error_pool)
	player.play()

func play_select():
	"""Alias for play_click - used for list/dropdown selections"""
	play_click()

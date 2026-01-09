extends Camera3D

@export var orbit_speed: float = 0.5
@export var orbit_radius: float = 12.0
@export var orbit_height: float = 8.0
@export var look_at_point: Vector3 = Vector3.ZERO

var angle: float = 0.0
var paused: bool = false

func _ready():
	angle = 0.0

func _process(delta):
	if paused:
		return
	
	# Smooth orbital rotation
	angle += orbit_speed * delta
	if angle > TAU:
		angle -= TAU
	
	# Calculate position on circular path
	var x = cos(angle) * orbit_radius
	var z = sin(angle) * orbit_radius
	
	# Update camera position and look at center
	position = Vector3(x, orbit_height, z)
	look_at(look_at_point, Vector3.UP)

func pause_orbit():
	paused = true

func resume_orbit():
	paused = false

func set_orbit_speed(speed: float):
	orbit_speed = speed

func set_orbit_radius(radius: float):
	orbit_radius = radius


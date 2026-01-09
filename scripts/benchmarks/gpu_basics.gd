extends Node3D
## Minimal GDScript wrapper for GPUBasicsScene C++ controller
## UI is handled by GDScript, all logic is in C++

var cpp_controller: GPUBasicsScene

func _ready():
	# Create C++ controller
	cpp_controller = GPUBasicsScene.new()
	add_child(cpp_controller)
	
	# Start benchmark (60 seconds)
	cpp_controller.start_test(60.0)
	
	print("[gpu_basics.gd] Benchmark started")

func _process(_delta):
	# C++ handles all processing
	# UI updates would go here if we had a UI
	pass

func _exit_tree():
	if cpp_controller:
		cpp_controller.stop_test()
	print("[gpu_basics.gd] Benchmark stopped")


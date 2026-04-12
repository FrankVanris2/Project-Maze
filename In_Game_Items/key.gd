extends Node3D

# How fast the key will spin on the Y-Axis
# (Positive Numbers Spin Counter Clockwise, Negative Numbers Spin Clockwise)
@export var spin_speed: float = 2.0

# Bonus: Let's make it bob up and down too!
@export var bob_height: float = 0.1
@export var bob_speed: float = 3.0
var time_passed:float = 0.0
var start_y: float

func _ready() -> void:
	# Remember where the C++ LevelPopulator placed us on the Y-axis should be 1.0
	start_y = global_position.y
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#1. Spin the key on the Y axis
	rotate_y(spin_speed * delta)
	
	#2. Bob it up and down using a Sine wave
	time_passed += delta
	global_position.y = start_y + (sin(time_passed * bob_speed) * bob_height)

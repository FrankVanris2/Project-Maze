extends Node3D

@export var spin_speed: float = 2.0
@export var bob_height: float = 0.1
@export var bob_speed: float = 3.0
@export var hover_offset: float = 0.3

@onready var floor_detector = $RayCast3D

var time_passed: float = 0.0
var start_y: float

func _ready() -> void:
	
	# 1. Force the laser to check the physics world
	floor_detector.force_raycast_update()
	
	# 2. Did the laser hit the floor?
	if floor_detector.is_colliding():
		var hit_point = floor_detector.get_collision_point()
		start_y = hit_point.y + hover_offset
		print("Key snapped to floor at Y: ", hit_point.y)
	else:
		start_y = global_position.y + hover_offset
		
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
		
	
func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)
	time_passed += delta
	global_position.y = start_y + (sin(time_passed * bob_speed) * bob_height)

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Because of our Layer setup, ONLY the player can trigger this now!
	print("The Key sees: ", body.name) 
	
	if body.has_method("add_item"):
		var was_picked_up = body.add_item("golden_key")
		if was_picked_up:
			queue_free()

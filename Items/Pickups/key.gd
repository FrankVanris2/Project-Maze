extends Node3D

@export var spin_speed: float = 2.0
@export var bob_height: float = 0.1
@export var bob_speed: float = 3.0
@export var hover_offset: float = 0.3

@onready var floor_detector = $RayCast3D

var time_passed: float = 0.0
var start_y: float
var is_animating_drop: bool = false

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	
	# Only snap immediately if the Maze Generator placed it.
	# If the player threw it, wait!
	if not is_animating_drop:
		_wait_and_snap()
		

func _wait_and_snap() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame	
	_snap_to_floor()
	
# We moved the floor logic into its own reusable function!
func _snap_to_floor() -> void:
	floor_detector.force_raycast_update()
	if floor_detector.is_colliding():
		var hit_point = floor_detector.get_collision_point()
		start_y = hit_point.y + hover_offset
		print("GPS: I hit the floor! Hovering at Y = ", start_y)
	else:
		start_y = global_position.y + hover_offset
		print("GPS: ERROR - My laser missed the floor! Floating at Y = ", start_y)

# --- TOSS LOGIC
func toss_from(start_pos: Vector3, target_pos: Vector3) -> void:
	is_animating_drop = true
	global_position = start_pos # Spawn inside the player's chest
	
	start_y = target_pos.y
	$Area3D.set_deferred("monitoring", false)
	
	# Create an animation to slide the key!
	var tween = create_tween()
	# Slide to the target position over 0.3 seconds using a smooth curve
	tween.tween_property(self, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# WHen the slide finishes, find the floor and turn bobbing back on!
	tween.tween_callback(func():
		is_animating_drop = false
		$Area3D.set_deferred("monitoring", true)
		print("GPS: I finished sliding! My exact coordinates are: ", global_position)
	)
	
		
func _process(delta: float) -> void:
	rotate_y(spin_speed * delta)
	
	# Only bob up and down if we are done sliding!
	if not is_animating_drop:
		time_passed += delta
		global_position.y = start_y + (sin(time_passed * bob_speed) * bob_height)

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Because of our Layer setup, ONLY the player can trigger this now!
	print("The Key sees: ", body.name) 
	
	if body.has_method("add_item"):
		var was_picked_up = body.add_item("golden_key")
		if was_picked_up:
			queue_free()

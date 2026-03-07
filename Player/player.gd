extends CharacterBody3D

const WALK_SPEED = 1.5
const RUN_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $Camera3D
@onready var stamina_bar = $UI/StaminaBar
@onready var stamina_component = $StaminaComponent # Grab our new Component!

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().physics_frame
	
func _unhandled_input(event):
	
	# Exiting the game method currently
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit();
		
	if event is InputEventMouseMotion:
		# Rotate the player left/right
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotate the Camera up and down
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(80), deg_to_rad(80))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# MOVEMENT & STAMINA ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back") 
	var is_moving = input_dir.length() > 0 # Are we actually pressing WASD?
	var trying_to_sprint = Input.is_action_pressed("sprint")
	
	# Ask the component to run the math and tell us if we are successfully sprinting
	var is_sprinting = stamina_component.process_stamina(delta, trying_to_sprint, is_moving)
	
	# Set speed based on the component's answer
	var current_speed = RUN_SPEED if is_sprinting else WALK_SPEED
	
	# Updating the UI directly from the component's variable
	stamina_bar.value = stamina_component.stamina
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

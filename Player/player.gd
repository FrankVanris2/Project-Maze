extends CharacterBody3D


const WALK_SPEED = 1.5
const RUN_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

# --- Stamina related information ---
const MAX_STAMINA = 100.0
var stamina = 100.0
var drain_rate = 40.0
var regen_rate = 30.0
var is_exhausted = false
var exhaustion_penalty_time = 2.0
var current_exhaustion_timer = 0.0

@onready var camera = $Camera3D
@onready var stamina_bar = $UI/StaminaBar

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
		
	# Sprinting Logic
	var current_speed = WALK_SPEED
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back") 
	var is_moving = input_dir.length() > 0 # Are we actually pressing WASD?
	
	if is_exhausted:
		# Penalty: Count down the timer before we can regenerate
		current_exhaustion_timer -= delta
		if current_exhaustion_timer <= 0.0:
			is_exhausted = false	
	else:
		# If holding Shift, moving, and we have stamina: SPRINT!
		if Input.is_action_pressed("sprint") and is_moving:
			current_speed = RUN_SPEED
			stamina -= drain_rate * delta
			
			# Did we just hit 0? Trigger the exhaustion penalty!
			if stamina <= 0.0:
				stamina = 0.0
				is_exhausted = true
				current_exhaustion_timer = exhaustion_penalty_time
				
		else:
			# Not sprinting? Regenerate stamina smoothly
			if stamina < MAX_STAMINA:
				stamina += regen_rate * delta
				if stamina > MAX_STAMINA:
					stamina = MAX_STAMINA
	
	# Updating the visual of the stamina Bar
	stamina_bar.value = stamina
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

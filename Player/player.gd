extends CharacterBody3D

# Item Database:
@export var droppable_items: Dictionary = {}
# GAME CONSTANTS
const WALK_SPEED = 1.5
const RUN_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

# GAME RELATED REFERENCES
@onready var camera = $Camera3D
@onready var stamina_bar = $UI/StaminaBar
@onready var stamina_component = $StaminaComponent # Grab our new Component!
@onready var inventory = $InventoryComponent
@onready var inventory_ui = $InventoryUI
@export var maze_generator: Node3D

# --- PLAYER RELATED SETUPS --- #
func add_item(item_name: String) -> bool:
		# We just pass the request down to the component
		if inventory:
			return inventory.add_item(item_name)
		return false

func get_item_count() -> int:
	if inventory:
		return inventory.items.size()
	return 0;
	
# --- GAME RELATED STARTUPS --- #
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# --- CONNECT THE OBSERVER ---
	inventory.inventory_updated.connect(inventory_ui._on_inventory_updated)
	inventory.active_slot_changed.connect(inventory_ui._on_active_slot_changed)
	inventory.item_dropped.connect(_on_item_dropped)
	# Waiting for the  C++ Nodes along with the Spawn Point to generate
	await get_tree().physics_frame
	
	# Asking the Scene Tree for any NODE in the "Spawn point" group
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	
	if spawn_points.size() > 0:
		# Teleport to the first SpawnPoint we found
		global_position = spawn_points[0].global_position
		print("Player cleanly Teleported via SOLID group Decoupling")
	else:
		print("No spawn point found in the world")
		
	
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

# --- INVENTORY ACTIONS ---
func _on_item_dropped(item_name: String) -> void:
	# 1. Check if the item exists in our database
	if not droppable_items.has(item_name):
		print("ERROR: No scene found in database for item: ", item_name)
		return
	
	# 2. Instantiate WHATEVER scene the database gave us
	var item_scene = droppable_items[item_name]
	var dropped_item = item_scene.instantiate()
		
	var camera_pos = camera.global_position
	var forward_direction = -camera.global_transform.basis.z.normalized()
	var ideal_drop_pos = camera_pos + (forward_direction * 1.0)
		
	var space_state = get_world_3d().direct_space_state
		
	var wall_query = PhysicsRayQueryParameters3D.create(camera_pos, ideal_drop_pos)
	wall_query.collision_mask = 1
	wall_query.exclude = [self.get_rid()]
		
	var wall_result = space_state.intersect_ray(wall_query)
	var final_drop_pos = ideal_drop_pos
		
	if wall_result:
		final_drop_pos = wall_result.position + (wall_result.normal * 0.2)
		
	var floor_query = PhysicsRayQueryParameters3D.create(final_drop_pos, final_drop_pos + Vector3(0, -50.0, 0))
	floor_query.collision_mask = 1
	var floor_result = space_state.intersect_ray(floor_query)
		
	if floor_result:
		# blindly trust that the item has a "hover_offset" property
		final_drop_pos.y = floor_result.position.y + dropped_item.hover_offset
	
	# Dynamically name it so you can find it in the Remote Tree
	dropped_item.name = "DROPPED_" + item_name.to_upper()
	
	dropped_item.is_animating_drop = true
	get_tree().current_scene.add_child(dropped_item)
	dropped_item.toss_from(camera_pos, final_drop_pos)
		
		

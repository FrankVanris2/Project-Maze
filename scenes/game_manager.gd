extends Node

# These allows us to drag and drop our placeholder scenes in the editor
@export var key_scene : PackedScene
@export var door_scene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait for the C++ maze to finish building and placing its invisible markerss
	await get_tree().physics_frame
	spawn_interactables()


func spawn_interactables():
	# --- SPAWN THE KEYS ---
	spawn_keys()
	
	# --- SPAWN THE DOORS ---
	spawn_doors()
	
	
func spawn_keys() :
	var key_markers = get_tree().get_nodes_in_group("key_spawn")
	for marker in key_markers:
		if key_scene:
			var new_key = key_scene.instantiate()
			# Copy the invisible marker's position
			new_key.global_position = marker.global_position
			# Add it to the new world
			add_child(new_key)
	print("Spawned: ", key_markers.size(), " Keys.")

func spawn_doors() :
	var door_markers = get_tree().get_nodes_in_group("exit_door")
	for marker in door_markers:
		if door_scene:
			var new_door = door_scene.instantiate()
			new_door.global_position = marker.global_position
			add_child(new_door)
	print("Spawned: ", door_markers.size(), " Doors.")
	
	

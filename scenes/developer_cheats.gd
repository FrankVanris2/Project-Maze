extends Node

#We export this so we can link the maze in the editor
@export var maze_generator: Node3D

#######################################################
# Developer Cheat key (Key CTRL + Key T): When pressing 
# these 2 keys you will have X-Ray capabilities to see 
# Everything within the maze.
#######################################################
func _process(_delta):
	# If we forgot to link the maze, just do nothing
	if not maze_generator:
		return
	
	# CHeck the physical state of the keyboard keys
	var holding_d = Input.is_physical_key_pressed(KEY_CTRL)
	var holding_t = Input.is_physical_key_pressed(KEY_T)
	
	# If BOTH keys are held down simultaneously, make the maze invisible
	if holding_d and holding_t:
		if maze_generator.visible:
			maze_generator.visible = false
			print("Cheat Active: X-Ray Vision ON")
	
	# If we let go of EITHER key, make sure the maze is visible
	else:
		if not maze_generator.visible:
			maze_generator.visible = true
			print("Cheat Deactivated: X-Ray Vision OFF")

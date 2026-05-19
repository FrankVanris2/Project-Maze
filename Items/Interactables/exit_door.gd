extends Node3D

# Tracking the count
var keys_inserted: int = 0

# Variables holding the 3 key slots of the door
@onready var slot1 = $KeySlot1
@onready var slot2 = $KeySlot2
@onready var slot3 = $KeySlot3

# The number of slots
@onready var door_key_slots = [slot1, slot2, slot3]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)


func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.has_method("get_item_count"):
		var keys_held = body.get_item_count()
		if keys_held >= 3:
			print("All 3 Keys Inserted! You ESCAPED THE MAZE! ")
			# For now we will just quit the game completely
			get_tree().quit()
		else:
			print("The door is locked tight. You have ", keys_held, " out of 3 keys")


func interact(player: CharacterBody3D) -> void:
	print("The Door was right-clicked: ", player.name)
	print("Current keys in door: ", keys_inserted)

extends Node3D


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

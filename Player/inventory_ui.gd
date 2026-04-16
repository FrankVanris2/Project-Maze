extends CanvasLayer


# Grab the 3 ColorRect slots we just made 
@onready var slots = $MarginContainer/HBoxContainer.get_children()

# The default empty color
var empty_color = Color(0.2, 0.2, 0.2, 0.8) # Dark Gray
func _on_inventory_updated(items: Array) -> void:
	# First, reset all 3 slots to empty gray
	for slot in slots:
		slot.color = empty_color
		
	# Now, looop through whatever is actually  in the inventory
	for i in range(items.size()):
		var item_name = items[i]
		
		# If it's a key, turn the slot bright yellow!
		if item_name == "golden_key":
			slots[i].color = Color(1.0, 0.8, 0.0, 1.0)
			
			# Later I can add more items 

extends CanvasLayer


# Grab the 3 ColorRect slots we just made 
@onready var slots = $MarginContainer/HBoxContainer.get_children()
var empty_color = Color(0.2, 0.2, 0.2, 0.8) # Dark Gray

func _ready() -> void:
	update_highlight(0) # when game starts force highlight slot 1
	
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

func _on_active_slot_changed(active_index: int) -> void:
	update_highlight(active_index)
	
func update_highlight(active_index: int) -> void:
	for i in range(slots.size()):
		if i == active_index:
			# Active Box: Full brightness, completely solid!
			slots[i].modulate = Color(1.0, 1.0, 1.0, 1.0)
			
			# Bonus Polish: Make it pop out slightly
			slots[i].scale = Vector2(1.1, 1.1)
			slots[i].pivot_offset = slots[i].size / 2.0
		else:
			# Inactive BOXES: Dimmed out and 50% transparent
			slots[i].modulate = Color(0.5, 0.5, 0.5, 1.0)
			slots[i].scale = Vector2(1.0, 1.0)

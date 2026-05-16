extends Node
class_name InventoryComponent

signal inventory_updated(items: Array) # --- ADD THIS SIGNAL ----
signal active_slot_changed(index: int)
signal item_dropped(item_name: String) # --- DROP ITEM SIGNAL ----

@export var max_capacity: int = 3
var items: Array = []
var active_slot_index: int = 0

# The input logic
func _unhandled_input(event: InputEvent) -> void:
	var slot_changed = false
	
	if event.is_action_pressed("slot_1"):
		active_slot_index = 0
		slot_changed = true
	elif event.is_action_pressed("slot_2"):
		active_slot_index = 1
		slot_changed = true
	elif event.is_action_pressed("slot_3"):
		active_slot_index = 2
		slot_changed = true
	elif event.is_action_pressed("inv_scroll_up"):
		active_slot_index -= 1
		if active_slot_index < 0:
			active_slot_index = max_capacity - 1
		slot_changed = true
	elif event.is_action_pressed("inv_scroll_down"):
		active_slot_index += 1
		if active_slot_index >= max_capacity:
			active_slot_index = 0
		slot_changed = true
	
	elif event.is_action_pressed("drop_item"):
			if active_slot_index < items.size():
				var item_to_drop = items[active_slot_index]
				items.remove_at(active_slot_index)
				inventory_updated.emit(items)
				item_dropped.emit(item_to_drop)
				print("Component dropped: ", item_to_drop)
	
	if slot_changed:
		active_slot_changed.emit(active_slot_index)
		
# The generic function to add ANY item, not just keyss
func add_item(item_name: String) -> bool:
	if items.size() < max_capacity:
		items.append(item_name)
		inventory_updated.emit(items)
		
		# Debugging purposes
		print("Item added: ", item_name)
		print("Inventory: ", items.size(), "/", max_capacity)
		return true
	else:
		print("Inventory is full!")
		return false

func has_item(item_name: String) -> bool:
	return items.has(item_name)
	
func remove_item(item_name: String) -> void:
	if items.has(item_name):
		items.erase(item_name)
		inventory_updated.emit(items)

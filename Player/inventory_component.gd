extends Node
class_name InventoryComponent

signal inventory_updated(items: Array) # --- ADD THIS SIGNAL ----

@export var max_capacity: int = 3
var items: Array = []

# The generic function to add ANY item, not just keyss
func add_item(item_name: String) -> bool:
	if items.size() < max_capacity:
		items.append(item_name)
		
		inventory_updated.emit(items)
		
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

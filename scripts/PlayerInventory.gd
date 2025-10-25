extends Node

# Singleton for managing player inventory across scenes

enum Item {
	POTTERY_1,
	POTTERY_2,
	POTTERY_3,
	SECRET_LETTER_X,
	MOMO_QUEST
}

var items: Array[Item] = []

func _ready() -> void:
	pass

# Add an item to the inventory
func add_item(item: Item) -> void:
	if not items.has(item):
		items.append(item)
		print("Added item to inventory: ", Item.keys()[item])
	else:
		print("Item already in inventory: ", Item.keys()[item])

# Remove an item from the inventory
func remove_item(item: Item) -> bool:
	if items.has(item):
		items.erase(item)
		print("Removed item from inventory: ", Item.keys()[item])
		return true
	else:
		print("Item not found in inventory: ", Item.keys()[item])
		return false

# Check if the inventory contains an item
func has_item(item: Item) -> bool:
	return items.has(item)

# Get all items in the inventory
func get_items() -> Array[Item]:
	return items.duplicate()

# Clear all items from the inventory
func clear_inventory() -> void:
	items.clear()
	print("Inventory cleared")

# Get the count of items in the inventory
func get_item_count() -> int:
	return items.size()

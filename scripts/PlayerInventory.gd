extends Node

# Singleton for managing player inventory across scenes

enum Item {
	POTTERY_1,
	POTTERY_2,
	POTTERY_3,
	SECRET_LETTER_F,
	SECRET_LETTER_R,
	SECRET_LETTER_E,
	SECRET_LETTER_S,
	SECRET_LETTER_H,
	MOMO_QUEST
}

const INITIAL_HEARTS: int = 3

var items: Array[Item] = []
var total_hearts: int = INITIAL_HEARTS

func _ready() -> void:
	GlobalSignals.player_hit.connect(_on_player_hit)

func _on_player_hit() -> void:
	remove_heart()

func get_total_hearts() -> int:
	return total_hearts

func remove_heart() -> void:
	if total_hearts > 0:
		total_hearts -= 1
		GlobalSignals.heart_lost.emit()
		
		if total_hearts == 0:
			GlobalSignals.player_out_of_hearts.emit()

# Reset hearts to full (called on scene reload/respawn)
func reset_hearts() -> void:
	total_hearts = INITIAL_HEARTS

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

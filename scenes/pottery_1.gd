extends "res://scenes/Collectible.gd"

func _ready() -> void:
	super._ready()
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_1):
		queue_free()

func _on_item_collected(_item_name: String) -> void:
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)

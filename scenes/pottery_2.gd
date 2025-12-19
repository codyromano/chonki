extends "res://scenes/Collectible.gd"

func _ready() -> void:
	super._ready()
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_2):
		queue_free()

func _on_item_collected(_item_name: String) -> void:
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_2)
	_check_pottery_completion()

func _check_pottery_completion() -> void:
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_1) and PlayerInventory.has_item(PlayerInventory.Item.POTTERY_2) and PlayerInventory.has_item(PlayerInventory.Item.POTTERY_3):
		GlobalSignals.queue_main_dialogue.emit(
			"Quest complete! Return to Momo for a reward.",
			"gus"
		)

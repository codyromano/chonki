extends "res://scenes/Collectible.gd"

func _ready() -> void:
	super._ready()
	# Hide pottery until player accepts Momo's quest
	if not PlayerInventory.has_item(PlayerInventory.Item.MOMO_QUEST):
		visible = false

func _process(delta: float) -> void:
	super._process(delta)
	# Show pottery once player accepts Momo's quest
	if not visible and PlayerInventory.has_item(PlayerInventory.Item.MOMO_QUEST):
		visible = true

func _on_item_collected(_item_name: String) -> void:
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_2)

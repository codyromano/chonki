extends "res://scenes/Collectible.gd"

func _ready() -> void:
	super._ready()

func _on_item_collected(_collectible_name: String) -> void:
	GlobalSignals.queue_main_dialogue.emit(
		"Hint: It looks like this forklift is plugged into something"
	)

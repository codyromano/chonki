extends "res://scenes/Collectible.gd"

func _ready() -> void:
	super._ready()

func _on_item_collected(_collectible_name: String) -> void:
	GlobalSignals.queue_main_dialogue.emit(
		"Hint: I don't have enough time to pull the lever by myself. One of my siblings might help if I can find a way to wake them up."
	)

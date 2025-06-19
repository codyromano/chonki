extends CharacterBody2D

func on_item_collected(item_name: String) -> void:
	print("You collected a " + item_name + "!")

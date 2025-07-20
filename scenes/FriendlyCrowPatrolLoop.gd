extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(_moving_toward_end: bool, crow_sprite: AnimatedSprite2D) -> void:
	# Flip the crow when returning to the start marker
	crow_sprite.flip_h = !crow_sprite.flip_h

	var branch_body: CharacterBody2D = crow_sprite.get_parent().find_child("Branch")
	if branch_body == null:
		return

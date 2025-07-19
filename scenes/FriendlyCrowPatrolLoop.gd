extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(moving_toward_end: bool, crow_sprite: AnimatedSprite2D) -> void:
	var branch: Sprite2D = crow_sprite.get_parent().find_child("Branch")
	# var branch_sprite: Sprite2D = branch.find_child("Sprite2D")

	# Flip the crow when returning to the start marker
	crow_sprite.flip_h = moving_toward_end
	crow_sprite.rotation_degrees = -crow_sprite.rotation_degrees

	branch.position = -branch.position
	branch.flip_h = !branch.flip_h
	branch.rotation_degrees = -branch.rotation_degrees

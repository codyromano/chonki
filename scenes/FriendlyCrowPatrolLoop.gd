extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(moving_toward_end: bool, crow_sprite: AnimatedSprite2D) -> void:
	# Flip the crow when returning to the start marker
	crow_sprite.flip_h = moving_toward_end
	crow_sprite.rotation_degrees = -crow_sprite.rotation_degrees
	
	var branch_body: CharacterBody2D = crow_sprite.get_parent().find_child("Branch")
	
	if branch_body == null:
		return
	
	var branch_sprite: Sprite2D = crow_sprite.get_parent().find_child("Branch").find_child("Sprite2D")

	branch_sprite.position = -branch_sprite.position
	branch_sprite.flip_h = !branch_sprite.flip_h
	branch_sprite.rotation_degrees = -branch_sprite.rotation_degrees

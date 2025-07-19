extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(moving_toward_end: bool, sprite: AnimatedSprite2D) -> void:
	var branch: Sprite2D = sprite.get_parent().find_child('Branch')
	
	# Flip the bicyclist when she's returning to the start marker
	sprite.flip_h = moving_toward_end 
	sprite.rotation_degrees = -sprite.rotation_degrees
	
	branch.position = -branch.position
	branch.flip_h = !branch.flip_h
	branch.rotation_degrees = -branch.rotation_degrees

extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(moving_toward_end: bool, sprite: AnimatedSprite2D) -> void:
	# Flip the crow when he's returning to the start marker
	sprite.flip_h = !moving_toward_end 
	
	sprite.rotation_degrees = -sprite.rotation_degrees

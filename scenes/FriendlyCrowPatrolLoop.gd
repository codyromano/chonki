extends "res://scenes/NPCLinearPatrolLoop.gd"

func _on_change_direction(moving_toward_end: bool, _sprite: AnimatedSprite2D) -> void:
	# Flip the crow when he's returning to the start marker
	_sprite.flip_h = !moving_toward_end 

	_sprite.rotation_degrees = -_sprite.rotation_degrees

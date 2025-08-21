extends CharacterBody2D

@export var is_flipped: bool = false

var last_movement_time: int = 0

func _ready() -> void:
	$AnimatedSprite2D.flip_h = is_flipped

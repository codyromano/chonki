extends "res://scenes/NPCLinearPatrolLoop.gd"

func _ready():
	super()
	GlobalSignals.biker_hit_branch.connect(_on_biker_hit_branch)

func _on_biker_hit_branch():
	if _patrol_tween:
		_patrol_tween.kill()
	sprite.play("concerned")

func _on_change_direction(moving_toward_end: bool, _sprite: AnimatedSprite2D) -> void:
	# Flip the bicyclist when she's returning to the start marker
	_sprite.flip_h = !moving_toward_end 
	#_sprite.rotation_degrees = -_sprite.rotation_degrees

extends "res://scenes/NPCLinearPatrolLoop.gd"

func _ready():
	super()
	GlobalSignals.biker_hit_branch.connect(_on_biker_hit_branch)
	GlobalSignals.biker_cleaned_up_branch.connect(_on_biker_cleaned_up_branch)

func _on_biker_hit_branch() -> void:
	if _patrol_tween:
		_patrol_tween.pause()
	sprite.play("concerned")
	await sprite.animation_finished
	GlobalSignals.biker_cleaned_up_branch.emit()
	
func _on_biker_cleaned_up_branch() -> void:
	sprite.play("default")
	_patrol_tween.play()
	
func _on_change_direction(moving_toward_end: bool, _sprite: AnimatedSprite2D) -> void:
	# Flip the bicyclist when she's returning to the start marker
	_sprite.flip_h = !moving_toward_end 
	#_sprite.rotation_degrees = -_sprite.rotation_degrees

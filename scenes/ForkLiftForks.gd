extends CharacterBody2D

@export var animation_duration: float = 5.0
@export var lever_distance: int = 3000

var move_tween: Tween
var initial_position: Vector2
var extended_position: Vector2

func _ready() -> void:
	initial_position = position
	extended_position = position + Vector2(0, lever_distance)
	
	GlobalSignals.lever_status_changed.connect(
		_lever_status_changed
	)

func _lever_status_changed(lever_name: String, is_on: bool) -> void:
	if lever_name != "fork_lift_lever":
		return
		
	if move_tween:
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(
		self,
		"position",
		extended_position if is_on else initial_position,
		animation_duration
	)

func _physics_process(_delta):
	pass

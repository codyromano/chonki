extends CharacterBody2D

@export var is_flipped: bool = false

var is_awake: bool = false
var last_movement_time: int = 0

const MOVEMENT_THRESHOLD = 500
	
func _process(_delta) -> void:
	print('velocity.x: ', velocity.x)
	# Any movement = awake; does not go back to sleep
	if velocity.x != 0:
		is_awake = true
	
	if !is_awake:
		return
		
	$AnimatedSprite2D.flip_h = velocity.x < MOVEMENT_THRESHOLD
		
		
	if abs(velocity.x) < MOVEMENT_THRESHOLD:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")

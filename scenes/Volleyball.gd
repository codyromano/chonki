extends StaticBody2D

@export var movement_distance: float = 500
@export var step: float = 100

var direction: int = -1
var initial_y_position: float

func _ready() -> void:
	initial_y_position = global_position.y

func _process(delta) -> void:
	global_position.y  += step * delta * direction
	
	# Reached the bottom; turn around
	if global_position.y >= initial_y_position + movement_distance:
		direction = -1
	elif global_position.y <= initial_y_position - movement_distance:
		direction = 1

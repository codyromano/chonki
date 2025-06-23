extends StaticBody2D

# How far the object will move to the right of its starting
# position before returning to its starting y position
@export var movement_distance_x: float = 250
# How far the object will move up from its starting position before
# returning to its starting x position
@export var movement_distance_y: float = 0
# How long in seconds for the object to travel its
# full x and y distances
@export var movement_speed_seconds: float = 1.0

var initial_position: Vector2
var time_elapsed: float = 0.0

func _ready() -> void:
	initial_position = global_position

func _process(delta) -> void:
	time_elapsed += delta
	
	# Calculate progress through the cycle (0 to 1)
	var cycle_progress = fmod(time_elapsed / movement_speed_seconds, 1.0)
	
	# Calculate X position using sine wave (smooth back and forth)
	var x_offset = sin(cycle_progress * 2 * PI) * movement_distance_x
	
	# Calculate Y position - only move upward from starting position
	# Using abs(cos) to keep it always positive (0 to 1 range)
	var y_offset = abs(cos(cycle_progress * 2 * PI)) * movement_distance_y
	
	# Apply the movement (negative y_offset to move up)
	global_position = initial_position + Vector2(x_offset, -y_offset)

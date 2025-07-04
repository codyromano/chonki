extends CharacterBody2D

# How far the object will move to the right of its starting
# position before returning to its starting y position
@export var movement_distance_x: float = 250
# How far the object will move up from its starting position before
# returning to its starting x position
@export var movement_distance_y: float = 0
# How long in seconds for the object to travel its
# full x and y distances
@export var movement_speed_seconds: float = 1.0

@export var rotation_setting: float = 50

var initial_position: Vector2
var time_elapsed: float = 0.0
var prev_position: Vector2
var _velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	initial_position = global_position
	prev_position = global_position

func _physics_process(delta) -> void:
	time_elapsed += delta
	$Sprite2D.rotation_degrees+= rotation_setting * delta
	# Calculate progress through the cycle (0 to 1)
	var cycle_progress = fmod(time_elapsed / movement_speed_seconds, 1.0)
	# Calculate X position using sine wave (smooth back and forth)
	var x_offset = sin(cycle_progress * 2 * PI) * movement_distance_x
	# Calculate Y position - only move upward from starting position
	# Using abs(cos) to keep it always positive (0 to 1 range)
	var y_offset = abs(cos(cycle_progress * 2 * PI)) * movement_distance_y
	# Apply the movement (negative y_offset to move up)
	var new_position = initial_position + Vector2(x_offset, -y_offset)
	_velocity = (new_position - prev_position) / delta
	global_position = new_position
	prev_position = new_position

func get_platform_velocity_custom() -> Vector2:
	return _velocity

extends Node2D

# Character to be moved
@export var body: Node2D

# Timing
@export var move_duration: float = 5.0

# Define the range of motion
@onready var start_marker: Marker2D = body.find_child('StartMarker')
@onready var end_marker: Marker2D = body.find_child('EndMarker')

# Store the initial global positions of the markers
var start_marker_pos: Vector2
var end_marker_pos: Vector2

@onready var sprite: AnimatedSprite2D = body.find_child('AnimatedSprite2D')

# Overriddable: Optionally, update the character changes direction.
func _on_change_direction(_moving_toward_end: bool, _sprite: AnimatedSprite2D) -> void:
	pass

func _ready():
	_validate_initial_nodes()
	start_marker_pos = start_marker.global_position
	end_marker_pos = end_marker.global_position
	body.global_position = start_marker_pos
	_patrol_to_next()

func _validate_initial_nodes() -> void:
	if body == null:
		push_error('Missing CharacterBody2D')
	if start_marker == null || end_marker == null:
		push_error('Missing start or end marker(s)')
	if sprite == null:
		push_error('Expected AnimatedSprite2D to exist in CharacterBody2D')

# Tween the body between start and end markers in a loop
var moving_to_end: bool = true


var _patrol_tween: Tween

func _patrol_to_next():
	if _patrol_tween:
		_patrol_tween.kill()
	_patrol_tween = create_tween()
	var to_pos = end_marker_pos if moving_to_end else start_marker_pos
	var tween = _patrol_tween.tween_property(body, "global_position", to_pos, move_duration)
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_patrol_tween.finished.connect(_on_patrol_reached_marker)

func _on_patrol_reached_marker():
	moving_to_end = !moving_to_end
	_on_change_direction(moving_to_end, sprite)
	_patrol_to_next()


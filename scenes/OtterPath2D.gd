extends Path2D

## Duration in seconds for the otter to complete one loop of the path
@export var loop_duration: float = 10.0
## How often to update rotation (in seconds). Lower = smoother but more calculations
@export var rotation_update_interval: float = 0.05

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var otter_area: Area2D = $PathFollow2D/OtterArea2D

var _tween: Tween
var _rotation_timer: float = 0.0

func _ready():
	# Disable automatic rotation, we'll handle it manually with tweening
	path_follow.rotates = false
	
	# Connect the area's body_entered signal to detect player collision
	otter_area.body_entered.connect(_on_body_entered)
	
	_start_movement()

func _on_body_entered(body: Node2D):
	if body.name == "ChonkiCharacter":
		GlobalSignals.player_hit.emit()

func _process(delta: float):
	_rotation_timer += delta
	if _rotation_timer >= rotation_update_interval:
		_rotation_timer = 0.0
		_update_rotation()

func _update_rotation():
	# Get the tangent (direction) at the current position on the path
	var progress_ratio = path_follow.progress_ratio
	var tangent = curve.sample_baked_with_rotation(progress_ratio * curve.get_baked_length()).x
	
	# Calculate the target rotation angle
	var target_rotation = tangent.angle()
	
	# Smoothly tween to the target rotation
	var rotation_tween = create_tween()
	rotation_tween.tween_property(path_follow, "rotation", target_rotation, rotation_update_interval).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func _start_movement():
	# Cancel any existing tween
	if _tween:
		_tween.kill()
	
	# Reset to the beginning of the path
	path_follow.progress = 0.0
	
	# Create a new tween for smooth movement
	_tween = create_tween()
	_tween.set_loops() # Loop infinitely
	
	# Get the total length of the curve
	var path_length = curve.get_baked_length()
	
	# Animate the progress from 0 to the full path length
	_tween.tween_property(path_follow, "progress", path_length, loop_duration)
	# After completing, reset to 0 for seamless looping
	_tween.tween_property(path_follow, "progress", 0.0, 0.0)

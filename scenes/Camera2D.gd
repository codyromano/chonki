extends Camera2D

@export var target: Node2D
@export var duration: float = 2.0

var tween: Tween
var initial_zoom: Vector2
var initial_position: Vector2

func _ready():
	# Store initial camera state
	initial_zoom = zoom
	initial_position = global_position
	
	# Connect to the win game signal
	GlobalSignals.win_game.connect(_on_win_game)

func _on_win_game():
	if not target:
		print("Warning: No target set for camera zoom")
		return
	
	# Create a new tween
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate simultaneously
	
	# Calculate target position (center on the target)
	var target_position = target.global_position
	
	# Define zoom level (you can adjust this value as needed)
	var target_zoom = Vector2(0.5, 0.5)  # Zoom in 3x
	
	# Animate position to target
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_property(self, "global_position", target_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Animate zoom
	tween.tween_property(self, "zoom", target_zoom, duration)
	tween.tween_property(self, "zoom", target_zoom, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# Optional: Function to reset camera to initial state
func reset_camera():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", initial_position, duration)
	tween.tween_property(self, "global_position", initial_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "zoom", initial_zoom, duration)
	tween.tween_property(self, "zoom", initial_zoom, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

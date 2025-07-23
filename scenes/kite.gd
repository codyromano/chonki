extends Area2D

var is_touching_player: bool = false
var tween
var swing_elapsed: float = 0.0  # time since player grabbed kite

const QUICK_SWING_DEGREES = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_gentle_swing()

func _physics_process(_delta):
	# If Chonki is hanging on, manually drive swing so acceleration is visible
	if is_touching_player:
		# update elapsed and speed factor
		swing_elapsed += _delta
		var factor = 1.0 + min(swing_elapsed * 0.1, 0.5)
		# ensure quick swing tween is running
		if tween:
			tween.set_speed_scale(factor)
		else:
			_start_quick_swing()
			tween.set_speed_scale(factor)
		# emit updated state for Chonki
		var shape_pos = $Polygon2D.global_position
		GlobalSignals.kite_rotated.emit(shape_pos, rotation_degrees, factor)
		return
func _start_gentle_swing() -> void:
	if tween:
		tween.kill()
		tween = null
		
	# Create an infinite looping tween to rock the kite left/right
	tween = create_tween()
	tween.set_loops()
	# Create rocking animation: rotate ±20° over 4 seconds each way with sine easing
	tween.tween_property(self, "rotation_degrees", 20.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", -20.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _start_quick_swing() -> void:
	if tween:
		tween.kill()
		tween = null
		
	# Create an infinite looping tween to rock the kite left/right
	tween = create_tween()
	tween.set_loops()
	# Create rocking animation: rotate ±20° over 4 seconds each way with sine easing
	tween.tween_property(self, "rotation_degrees", -QUICK_SWING_DEGREES, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", QUICK_SWING_DEGREES, 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _on_body_entered(_body):
	if !is_touching_player:
		$WindBackgroundSFX.play()
		# Stop tween and reset manual swing timer
		if tween:
			tween.kill()
			tween = null
		# Initialize manual swing phase from current rotation
		var norm = clamp(rotation_degrees / QUICK_SWING_DEGREES, -1.0, 1.0)
		var initial_phase = asin(norm) * 4.0 / PI
		swing_elapsed = initial_phase
		is_touching_player = true
		# Emit kite center and rotation for Chonki to hang
		var shape_pos = $Polygon2D.global_position
		GlobalSignals.chonki_touched_kite.emit(shape_pos, rotation_degrees)

func _on_body_exited(_body):
	$WindBackgroundSFX.stop()
	$WindWhooshSFX.play()
	is_touching_player = false
	_start_gentle_swing()

extends Area2D

var is_touching_player: bool = false
var tween

const QUICK_SWING_DEGREES = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_gentle_swing()

func _physics_process(_delta):
	if is_touching_player:
		var shape_pos = $Polygon2D.global_position
		GlobalSignals.kite_rotated.emit(shape_pos, rotation_degrees)
		
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
		is_touching_player = true
	   # Emit kite center and rotation for Chonki to hang
		var shape_pos = $Polygon2D.global_position
		GlobalSignals.chonki_touched_kite.emit(shape_pos, rotation_degrees)
		_start_quick_swing()

func _on_body_exited(_body):
	is_touching_player = false
	_start_gentle_swing()

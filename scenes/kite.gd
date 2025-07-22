extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create an infinite looping tween to rock the kite left/right
	var tween = create_tween()
	tween.set_loops()
	# Create rocking animation: rotate ±20° over 4 seconds each way with sine easing
	tween.tween_property(self, "rotation_degrees", 20.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation_degrees", -20.0, 4.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	# Tween handles animation; no per-frame processing needed


func _on_body_entered(body):
	GlobalSignals.chonki_touched_kite.emit(rotation_degrees)

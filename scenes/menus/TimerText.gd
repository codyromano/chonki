extends Label

@export var duration: int = 90

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = str(duration)

func _on_timer_timeout():
	if duration == 0:
		GlobalSignals.time_up.emit()
		$Timer.queue_free()
		
	duration = max(0, duration - 1)
		

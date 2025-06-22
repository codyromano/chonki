extends Label

@export var duration: int = 90

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = str(duration)
	GlobalSignals.win_game.connect(stop_timer)

func stop_timer() -> void:
	$Timer.queue_free()

func _on_timer_timeout():
	if duration == 0:
		GlobalSignals.time_up.emit()
		stop_timer()
		
	duration = max(0, duration - 1)
		

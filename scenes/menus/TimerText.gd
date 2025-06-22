extends Label

@export var duration: int = 90

func _ready() -> void:
	GlobalSignals.win_game.connect(stop_timer)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = str(duration)

func stop_timer() -> void:
	if $Timer:
		$Timer.queue_free()

func _on_timer_timeout():
	if duration == 0:
		GlobalSignals.time_up.emit()
		stop_timer()
		
	duration = max(0, duration - 1)
		

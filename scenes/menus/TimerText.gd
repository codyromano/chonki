extends Label

func _ready() -> void:
	GlobalSignals.win_game.connect(stop_timer)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = str(GameState.time_elapsed)
	# Update GameState.time_elapsed as time spent (not time left)

func stop_timer() -> void:
	if $Timer:
		$Timer.queue_free()

func _on_timer_timeout():		
	GameState.time_elapsed+= 1
		

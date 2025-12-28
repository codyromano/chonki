extends CharacterBody2D

func _ready() -> void:
	GlobalSignals.win_game.connect(on_game_won)

func on_game_won(_zoom_intensity: float = 0.5) -> void:
	var timer = Timer.new()
	timer.one_shot = true 
	timer.autostart = true
	
	timer.connect("timeout", func ():
		$BackgroundAudio.stop()
		$ChillBark.play()
		$AudioWon.play()
		timer.call_deferred("queue_free")
	)
	add_child(timer)
	timer.start(1.5)

func on_item_collected(_item_name: String) -> void:
	GlobalSignals.star_collected.emit()
	
func is_attacking() -> bool:
	return $AnimatedSprite2D.animation in ["ram", "push"]

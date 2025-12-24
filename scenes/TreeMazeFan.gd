extends AnimatedSprite2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)
	play("default")
	if audio_player:
		audio_player.stop()

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if lever_name != "tree_maze_lever":
		return
	
	if is_on:
		play("on")
		if audio_player:
			audio_player.play()
	else:
		play("default")
		if audio_player:
			audio_player.stop()

extends Node2D

var player_moved_initially: bool = false

func _ready():
	GlobalSignals.game_zoom_level.emit(0.2)
	
func _process(_delta) -> void:
	if !player_moved_initially && (Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right")):
		player_moved_initially = true
		# Zoom out a bit to see all the puppies and mother corgi
		GlobalSignals.game_zoom_level.emit(0.15)		


func _on_little_free_library_body_entered(body):
	pass # Replace with function body.

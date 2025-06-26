@tool
extends Node2D

var previous_scene_path: String = ""

func _ready():
	previous_scene_path = FadeTransition._previous_scene_path
	
	# Connect Replay button
	var replay_btn = get_node_or_null("Control/ButtonContainer/HBoxContainer/Replay")
	if replay_btn:
		replay_btn.pressed.connect(_on_replay_pressed)

func _on_replay_pressed():
	FadeTransition.fade_out_and_change_scene(previous_scene_path, 0.0, 1.0)

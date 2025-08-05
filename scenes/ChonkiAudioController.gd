# ChonkiAudioController.gd
extends Node

var run_sound: AudioStreamPlayer2D
var rest_sound: AudioStreamPlayer2D
var jump_sound: AudioStreamPlayer2D
var ouch_sound: AudioStreamPlayer2D
var chill_bark_sound: AudioStreamPlayer2D

func _ready() -> void:
	# Find nodes by name recursively from the current scene's root
	# Note: This is less performant than using @export vars or direct paths.
	run_sound = get_tree().current_scene.find_child("AudioRun", true, false)
	rest_sound = get_tree().current_scene.find_child("RestRun", true, false)
	jump_sound = get_tree().current_scene.find_child("AudioJump", true, false)
	ouch_sound = get_tree().current_scene.find_child("AudioOuch", true, false)
	chill_bark_sound = get_tree().current_scene.find_child("ChillBark", true, false)

	GlobalSignals.connect("play_sfx", _on_play_sfx)
	GlobalSignals.connect("stop_sfx", _on_stop_sfx)

func _on_play_sfx(sound_name: String) -> void:
	var sound_player: AudioStreamPlayer2D
	match sound_name:
		"jump":
			sound_player = jump_sound
		"run":
			sound_player = run_sound
		"rest":
			sound_player = rest_sound
		"ouch":
			sound_player = ouch_sound
		"chill_bark":
			sound_player = chill_bark_sound
	
	if sound_player and not sound_player.playing:
		sound_player.play()

func _on_stop_sfx(sound_name: String) -> void:
	match sound_name:
		"run":
			run_sound.stop()
		"rest":
			rest_sound.stop()

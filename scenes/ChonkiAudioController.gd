# ChonkiAudioController.gd
extends Node

var run_sound: AudioStreamPlayer2D
var rest_sound: AudioStreamPlayer2D
var jump_sound: AudioStreamPlayer2D
var midair_jump_sound: AudioStreamPlayer2D
var ouch_sound: AudioStreamPlayer2D
var chill_bark_sound: AudioStreamPlayer2D

func _ready() -> void:
	# Connect to player registration signals
	GlobalSignals.connect("player_registered", _on_player_registered)
	GlobalSignals.connect("player_unregistered", _on_player_unregistered)
	
	# Connect to SFX signals
	GlobalSignals.connect("play_sfx", _on_play_sfx)
	GlobalSignals.connect("stop_sfx", _on_stop_sfx)

func _on_player_registered(player: Node2D) -> void:
	# Find audio nodes from the player reference instead of current_scene
	run_sound = player.find_child("AudioRun", true, false)
	rest_sound = player.find_child("RestRun", true, false)
	jump_sound = player.find_child("AudioJump", true, false)
	midair_jump_sound = player.find_child("AudioMidairJump", true, false)
	ouch_sound = player.find_child("AudioOuch", true, false)
	chill_bark_sound = player.find_child("ChillBark", true, false)

func _on_player_unregistered() -> void:
	# Clear audio node references when player leaves
	run_sound = null
	rest_sound = null
	jump_sound = null
	midair_jump_sound = null
	ouch_sound = null
	chill_bark_sound = null

func _on_play_sfx(sound_name: String) -> void:
	var sound_player: AudioStreamPlayer2D
	match sound_name:
		"jump":
			sound_player = jump_sound
		"midair_jump":
			sound_player = midair_jump_sound
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
			if run_sound:
				run_sound.stop()
		"rest":
			if rest_sound:
				rest_sound.stop()

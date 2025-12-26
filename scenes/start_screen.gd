extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var press_enter_label: Label = $CenterContainer2/VBoxContainer/PressEnterLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	fade_overlay.visible = false
	_start_pulse_animation()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()

func _start_game() -> void:
	set_process_input(false)
	
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	fade_tween.tween_property(audio_player, "volume_db", -80.0, 1.0)
	
	await fade_tween.finished
	
	GlobalSignals.on_unload_scene.emit(get_tree().current_scene.scene_file_path if get_tree().current_scene else "")
	get_tree().change_scene_to_file("res://scenes/opening_animation_sequence.tscn")

func _start_pulse_animation() -> void:
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(press_enter_label, "modulate:a", 0.3, 1.5)
	pulse_tween.tween_property(press_enter_label, "modulate:a", 1.0, 1.5)

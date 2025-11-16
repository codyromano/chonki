extends Control

@onready var fade_overlay: ColorRect = $FadeOverlay

func _ready() -> void:
	fade_overlay.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()

func _start_game() -> void:
	set_process_input(false)
	
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	
	await fade_tween.finished
	
	get_tree().change_scene_to_file("res://scenes/opening_animation_sequence.tscn")

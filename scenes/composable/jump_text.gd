extends "res://scenes/composable/instructional_text.gd"

func _ready() -> void:
	super._ready()
	
# Override
func _should_dismiss() -> bool:
	return Input.is_action_just_pressed("ui_up")

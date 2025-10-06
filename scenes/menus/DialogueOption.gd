extends Button

var option_id: String = ""
var option_text: String = ""

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)

func setup(id: String, choice_text: String) -> void:
	option_id = id
	option_text = choice_text
	text = choice_text

func _on_focus_entered() -> void:
	# Ensure this button is visible when focused
	pass

func _unhandled_input(event: InputEvent) -> void:
	if has_focus() and event.is_action_pressed("read"):
		GlobalSignals.dialogue_option_selected.emit(option_id, option_text)
		get_viewport().set_input_as_handled()

extends PanelContainer

@onready var label: Label = $Label

var dialogue: String

func _ready() -> void:
	label.text = dialogue

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("read"):
		GlobalSignals.dismiss_active_main_dialogue.emit()
		# Stop the event from propagating further and prevent multiple dismissals.
		get_viewport().set_input_as_handled()

extends PanelContainer

@onready var label: Label = $Label

var dialogue: String
var instruction_trigger_id: String = ""

func _ready() -> void:
	label.text = dialogue

func set_instruction_trigger_id(trigger_id: String) -> void:
	instruction_trigger_id = trigger_id

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("read") or event.is_action_pressed("jump"):
		GlobalSignals.dismiss_active_main_dialogue.emit(instruction_trigger_id)
		# Stop the event from propagating further and prevent multiple dismissals.
		get_viewport().set_input_as_handled()

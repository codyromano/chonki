extends PanelContainer

@export var dialogue: String = "Hello, world"
@export var duration: float = 3.0

@onready var typewriter: Label = find_child('TypewriterReveal')

var instruction_trigger_id: String = ""

func _ready():
	typewriter.text_after_reveal = dialogue
	typewriter.animation_duration = duration

func set_instruction_trigger_id(trigger_id: String) -> void:
	instruction_trigger_id = trigger_id

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("read") or event.is_action_pressed("jump"):
		GlobalSignals.dismiss_active_main_dialogue.emit(instruction_trigger_id)
		# Stop the event from propagating further and prevent multiple dismissals.
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()

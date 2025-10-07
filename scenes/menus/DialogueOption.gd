extends Button

var option_id: String = ""
var option_text: String = ""

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	pressed.connect(_on_pressed)

func setup(id: String, choice_text: String) -> void:
	option_id = id
	option_text = choice_text
	text = choice_text

func _on_focus_entered() -> void:
	pass

func _on_pressed() -> void:
	GlobalSignals.dialogue_option_selected.emit(option_id, option_text)

# Handle "read" action as if button was pressed
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("read"):
		accept_event()
		_on_pressed()

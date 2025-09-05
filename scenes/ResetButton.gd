extends Button

func _ready() -> void:
	visible = false
	GlobalSignals.on_data_button_selected.connect(
		_on_data_button_selected
	)
	
	GlobalSignals.press_reset_anagram.connect(
		_press_reset_anagram
	)
	
func _on_data_button_selected(id: String, data: String) -> void:
	if id == 'letter_button':
		visible = true

func _press_reset_anagram() -> void:
	visible = false

func _on_pressed():
	GlobalSignals.press_reset_anagram.emit()

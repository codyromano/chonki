extends Label

@export var total_letters: int = 5

var selected_letters: String
	
func _ready():
	GlobalSignals.on_data_button_selected.connect(_on_data_button_selected)
	_update_letter_display()

func _update_letter_display() -> void:
	var result = selected_letters
	
	for i in total_letters - selected_letters.length():
		result += '_'
	
	text = result
		
func _on_data_button_selected(id: String, data: String) -> void:
	if id == "letter_button":
		selected_letters += data
		_update_letter_display()
		

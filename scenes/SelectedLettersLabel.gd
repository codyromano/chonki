extends Label

@export var total_letters: int = 5

var selected_letters: String
	
func _ready():
	GlobalSignals.on_data_button_selected.connect(_on_data_button_selected)
	GlobalSignals.press_reset_anagram.connect(_on_press_reset_anagram)
	_update_letter_display()
	GlobalSignals.anagram_word_guess_updated.emit(selected_letters)

func _update_letter_display() -> void:
	var result = selected_letters
	
	for i in total_letters - selected_letters.length():
		result += '_'
	
	text = result
		
func _on_data_button_selected(id: String, data: String) -> void:
	if id != "letter_button":
		return
		
	get_parent().find_child('PopAudio').play()
		
	selected_letters += data
	_update_letter_display()
	GlobalSignals.anagram_word_guess_updated.emit(selected_letters)
	print('selected: ' + selected_letters)

func _on_press_reset_anagram() -> void:
	selected_letters = ''
	_update_letter_display()
	GlobalSignals.anagram_word_guess_updated.emit(selected_letters)
		

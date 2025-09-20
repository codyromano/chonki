extends Label

func _ready() -> void:
	var total_solution_word_letters = GameState.get_current_level_puzzle_solution().length()
	var total_letters_collected = GameState.get_collected_letters().size()
	
	if total_solution_word_letters == total_letters_collected:
		text = "Spell a word to learn more of Gus's story"
	else:
		text = "You need " + str(total_solution_word_letters) + " mystery letters to solve this puzzle (" + str(total_letters_collected) + " collected). Come back after you've found all the letters."

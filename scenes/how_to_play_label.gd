extends Label

func _ready() -> void:
	var total_solution_word_letters = GameState.get_current_level_puzzle_solution().length()
	var total_letters_collected = GameState.get_collected_letters().size()
	
	if total_solution_word_letters == total_letters_collected:
		text = "Can you form a word from the " + str(total_letters_collected) + " letters you collected?"
	else:
		text = "You can't solve this puzzle yet. You have only collected " + str(total_letters_collected) + "/" + str(total_solution_word_letters) + " letters."

extends GutTest

var secret_letter_scene = preload("res://scenes/SecretLetter.tscn")
var secret_letter: Control
var signal_emitted: bool = false
var gamestate_updated_before_signal: bool = false
var collected_letter: String = ""

func before_each():
	secret_letter = secret_letter_scene.instantiate()
	add_child_autofree(secret_letter)
	
	signal_emitted = false
	gamestate_updated_before_signal = false
	collected_letter = ""
	
	GameState.current_level = 2
	if GameState.letters_collected_by_scene.has(2):
		GameState.letters_collected_by_scene[2] = []

func after_each():
	secret_letter = null
	if GameState.letters_collected_by_scene.has(2):
		GameState.letters_collected_by_scene[2] = []

func test_gamestate_updated_before_signal_emission():
	secret_letter.letter = "T"
	
	GlobalSignals.secret_letter_collected.connect(_on_signal_received)
	
	secret_letter._start_collection_sequence()
	
	await get_tree().process_frame
	
	assert_true(signal_emitted, "Signal should have been emitted")
	assert_true(gamestate_updated_before_signal, "GameState should be updated before signal emission")
	assert_eq(collected_letter, "T", "Collected letter should match")

func test_letter_added_to_gamestate():
	secret_letter.letter = "E"
	
	assert_eq(GameState.get_collected_letters().size(), 0, "Should start with no letters")
	
	secret_letter._start_collection_sequence()
	
	await get_tree().process_frame
	
	var letters = GameState.get_collected_letters()
	assert_eq(letters.size(), 1, "Should have 1 letter after collection")
	assert_has(letters, "E", "Should contain the collected letter")

func test_signal_carries_correct_letter():
	secret_letter.letter = "S"
	
	GlobalSignals.secret_letter_collected.connect(_on_signal_received)
	
	secret_letter._start_collection_sequence()
	
	await get_tree().process_frame
	
	assert_eq(collected_letter, "S", "Signal should carry the correct letter")

func _on_signal_received(letter: String):
	signal_emitted = true
	collected_letter = letter
	
	var letters_in_state = GameState.get_collected_letters()
	if letters_in_state.size() > 0 and letters_in_state.has(letter):
		gamestate_updated_before_signal = true

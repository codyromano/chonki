extends Control

@export var win_word: String

@onready var overall_game_container: MarginContainer = find_child('AnagramMarginContainer')
@onready var button_scene: PackedScene = preload("res://scenes/select_letter_button.tscn")
@onready var container: HBoxContainer = find_child('SelectLettersButtonContainer')
@onready var selected_letters_label: Label = find_child('SelectedLettersLabel')
@onready var reset_button: Button = find_child('ResetButton')

const WIN_FADEOUT_DURATION: float = 1.5

func _ready():
	print("[LittleFreeLibrary] _ready() called, win_word: '", win_word, "'")
	create_select_letter_buttons()
	selected_letters_label.total_letters = win_word.length()
	
	GlobalSignals.press_reset_anagram.connect(_on_press_reset_anagram)
	GlobalSignals.anagram_word_guess_updated.connect(_on_anagram_word_guess_updated)
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dismiss_active_dialogue)
	print("[LittleFreeLibrary] Signals connected, ready for player input")
	
func _on_dismiss_active_dialogue(_instruction_trigger_id: String) -> void:
	SceneStack.pop_scene()
	
func _on_win() -> void:
	print("[LittleFreeLibrary] _on_win() called - player solved the puzzle!")
	var win_audio: AudioStreamPlayer = find_child('WinAudio')
	win_audio.play()
	
	print("[LittleFreeLibrary] Starting fadeout animation")
	var tween = create_tween()
	tween.tween_property(overall_game_container, 'modulate:a', 0, WIN_FADEOUT_DURATION)
	await tween.finished
	
	var dialogue_text: String
	if GameState.current_level == 2:
		dialogue_text = "Gus and Dave experience fresh air for the first time in ages"
	else:
		dialogue_text = "Gus, the Corgi, was born in a barn in Olympia, Washington. His future owner drove from Seattle to pick him up."
	
	print("[LittleFreeLibrary] Fadeout complete, emitting queue_main_dialogue signal")
	GlobalSignals.queue_main_dialogue.emit(
		dialogue_text,
		"",
		"gus"
	)
	print("[LittleFreeLibrary] queue_main_dialogue signal emitted")
		
func _on_anagram_word_guess_updated(word: String) -> void:
	print("[LittleFreeLibrary] Word guess updated: '", word, "' (win_word: '", win_word, "')")
	if word.to_lower() == win_word:
		print("[LittleFreeLibrary] Word matches! Calling _on_win()")
		_on_win()
	else:
		print("[LittleFreeLibrary] Word doesn't match yet")

func add_single_button(index: int, letter: String) -> Button:
	var button = button_scene.instantiate()
	button.id = 'letter_button'
	button.data = letter
	button.rendering_order = index
	
	container.add_child(button)
	return button

func create_select_letter_buttons() -> void:
	var letters_array = Array(GameState.get_collected_letters())
	print("[LittleFreeLibrary] Creating buttons for letters: ", letters_array)
	if letters_array.is_empty():
		print("[LittleFreeLibrary] WARNING: No letters collected, cannot create puzzle!")
		return
		
	letters_array.shuffle()
	print("[LittleFreeLibrary] Shuffled letters: ", letters_array)
	
	# Create a button for the first letter and focus on it
	var first_button = add_single_button(0, letters_array[0])
	first_button.grab_focus()
	
	var buttons = [first_button]
	
	# Create the remaining letters:
	for i in range(1, letters_array.size()):
		buttons.append(add_single_button(i, letters_array[i]))
	
	print("[LittleFreeLibrary] Created ", buttons.size(), " letter buttons")

func _on_press_reset_anagram() -> void:
	var buttons = container.get_children()
	for button in buttons:
		button.call_deferred("queue_free")
		
	create_select_letter_buttons()

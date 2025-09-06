extends Control

@export var win_word: String

@onready var overall_game_container: MarginContainer = find_child('AnagramMarginContainer')
@onready var button_scene: PackedScene = preload("res://scenes/select_letter_button.tscn")
@onready var container: HBoxContainer = find_child('SelectLettersButtonContainer')
@onready var selected_letters_label: Label = find_child('SelectedLettersLabel')
@onready var reset_button: Button = find_child('ResetButton')

const WIN_FADEOUT_DURATION: float = 1.5

func _ready():
	create_select_letter_buttons()
	selected_letters_label.total_letters = win_word.length()
	
	GlobalSignals.press_reset_anagram.connect(_on_press_reset_anagram)
	GlobalSignals.anagram_word_guess_updated.connect(_on_anagram_word_guess_updated)
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dismiss_active_dialogue)
	# Debugging
	# _on_win()

func _on_dismiss_active_dialogue() -> void:
	print("Story content dismissed - calling SceneStack.pop_scene()")
	SceneStack.pop_scene()
	
func _on_win() -> void:
	var win_audio: AudioStreamPlayer = find_child('WinAudio')
	win_audio.play()
	
	var tween = create_tween()
	tween.tween_property(overall_game_container, 'modulate:a', 0, WIN_FADEOUT_DURATION)
	await tween.finished
	
	GlobalSignals.queue_main_dialogue.emit('Gus, the Corgi, was born in a barn in Olympia, Washington. His future owner drove from Seattle to pick him up.')
		
func _on_anagram_word_guess_updated(word: String) -> void:
	print("progress: " + word + " vs. " + win_word)
	if word == win_word:
		_on_win()
	
func create_select_letter_buttons() -> void:
	var letters_array = Array(win_word.split())
	letters_array.shuffle()
	
	for letter in letters_array:
		var button = button_scene.instantiate()
		button.id = 'letter_button'
		button.data = letter
		
		container.add_child(button)

func _on_press_reset_anagram() -> void:
	var buttons = container.get_children()
	for button in buttons:
		button.call_deferred("queue_free")
		
	create_select_letter_buttons()

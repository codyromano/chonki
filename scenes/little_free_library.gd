extends Control

@export var win_word: String
@onready var button_scene: PackedScene = preload("res://scenes/select_letter_button.tscn")
@onready var container: HBoxContainer = find_child('SelectLettersButtonContainer')
@onready var selected_letters_label: Label = find_child('SelectedLettersLabel')

func _ready():
	create_select_letter_buttons()
	selected_letters_label.total_letters = win_word.length()

func create_select_letter_buttons() -> void:
	var letters_array = Array(win_word.split())
	letters_array.shuffle()
	
	for letter in letters_array:
		var button = button_scene.instantiate()
		button.id = 'letter_button'
		button.data = letter
		
		container.add_child(button)

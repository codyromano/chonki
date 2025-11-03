extends CanvasLayer

# Hide/show menu functionality
@export var is_health_visible: bool = false
@export var is_timer_visible: bool = false

# Configure available resources in level
@export var hearts_available: int = 3
@export var total_books_in_level: int = 5
@export var total_letters_in_level: int = 5

# Preload UI resources
@onready var timer_label: Label = find_child('TimerText')
@onready var timer_icon: TextureRect = find_child('ClockIcon')
@onready var star_label: Label = find_child('StarLabel')
@onready var letters_container: HBoxContainer = find_child('LettersHBoxContainer')

var books_collected: int = 0
var letter_labels: Array[Label] = []

func _ready():
	GlobalSignals.star_collected.connect(_on_star_collected)
	GlobalSignals.heart_lost.connect(_on_heart_lost)
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	# Initialize letter display with underscores
	_initialize_letter_display()
	
	# Load any letters that were already collected in this level
	_load_existing_letters()
	
	if !is_health_visible:
		_hide_health()
	
	if !is_timer_visible:
		_hide_timer()

func _initialize_letter_display() -> void:
	# Create labels for all letter slots (showing underscores initially)
	if letters_container:
		for i in range(total_letters_in_level):
			var letter_label = Label.new()
			letter_label.text = "_"
			letter_label.add_theme_font_size_override("font_size", 50)
			letter_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))  # Gray for uncollected
			letters_container.add_child(letter_label)
			letter_labels.append(letter_label)

func _load_existing_letters() -> void:
	# Display any letters that were already collected in this level
	var collected_letters = GameState.get_collected_letters()
	for i in range(collected_letters.size()):
		if i < letter_labels.size():
			_update_letter_at_index(i, collected_letters[i])

func _display_letter(letter: String) -> void:
	# Find the next available slot (underscore) and update it
	var collected_letters = GameState.get_collected_letters()
	var index = collected_letters.size() - 1  # The letter was just added to GameState
	
	if index >= 0 and index < letter_labels.size():
		_update_letter_at_index(index, letter)

func _update_letter_at_index(index: int, letter: String) -> void:
	if index < letter_labels.size():
		letter_labels[index].text = letter
		letter_labels[index].add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))  # Gold color

func _on_star_collected() -> void:
	books_collected += 1
	GameState.stars_collected = books_collected

func _on_heart_lost() -> void:
	var current_hearts = PlayerInventory.get_total_hearts()
	var heart_node = find_child("Heart" + str(current_hearts + 1))
	if heart_node:
		heart_node.queue_free()

func _on_secret_letter_collected(letter: String) -> void:
	_display_letter(letter)

func _hide_health() -> void:
	# Find all nodes that start with "Heart" using glob pattern
	var heart_nodes = find_children("Heart*")
	for heart_node in heart_nodes:
		heart_node.queue_free.call_deferred()

func _hide_timer() -> void:
	timer_label.queue_free.call_deferred()
	timer_icon.queue_free.call_deferred()
	
func _process(_delta):
	star_label.text = str(books_collected) + "/" + str(total_books_in_level)

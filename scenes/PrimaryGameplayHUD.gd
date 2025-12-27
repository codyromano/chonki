extends CanvasLayer

@export var debug_mode: bool = false
@export var debug_letters: Array[String] = ["F", "R", "E", "S", "H"]

# Configure available resources in level
@export var hearts_available: int = 3
@export var total_books_in_level: int = 5
@export var total_letters_in_level: int = 5

var sniglet_font: FontFile = preload("res://fonts/Sniglet-Regular.ttf")

# Preload UI resources
@onready var star_label: Label = find_child('StarLabel')
@onready var letters_container: HBoxContainer = find_child('LettersHBoxContainer')

var books_collected: int = 0
var letter_labels: Array[Label] = []
var debug_menu: VBoxContainer

func _ready():
	GlobalSignals.star_collected.connect(_on_star_collected)
	GlobalSignals.heart_lost.connect(_on_heart_lost)
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	books_collected = GameState.stars_collected
	
	_initialize_letter_display()
	_load_existing_letters()
	
	if debug_mode:
		_initialize_debug_menu()

func _initialize_letter_display() -> void:
	if letters_container:
		for i in range(total_letters_in_level):
			var letter_label = Label.new()
			letter_label.text = "_"
			letter_label.add_theme_font_override("font", sniglet_font)
			letter_label.add_theme_font_size_override("font_size", 50)
			letter_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			letters_container.add_child(letter_label)
			letter_labels.append(letter_label)

func _load_existing_letters() -> void:
	# Display any letters that were already collected in this level
	var collected_letters = GameState.get_collected_letters()
	for i in range(collected_letters.size()):
		if i < letter_labels.size():
			_update_letter_at_index(i, collected_letters[i])

func _display_letter(letter: String) -> void:
	var collected_letters = GameState.get_collected_letters()
	var index = collected_letters.size() - 1
	
	if index >= 0 and index < letter_labels.size():
		_update_letter_at_index(index, letter)

func _update_letter_at_index(index: int, letter: String) -> void:
	if index < letter_labels.size():
		var uppercase_letter = letter.to_upper()
		letter_labels[index].text = uppercase_letter
		letter_labels[index].add_theme_color_override("font_color", Color(1.0, 1.0, 0.529412))

func _initialize_debug_menu() -> void:
	debug_menu = VBoxContainer.new()
	debug_menu.name = "DebugMenu"
	debug_menu.position = Vector2(300, 100)
	
	var debug_title = Label.new()
	debug_title.text = "DEBUG: Collect Letters"
	debug_title.add_theme_font_size_override("font_size", 20)
	debug_title.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0))
	debug_menu.add_child(debug_title)
	
	for letter in debug_letters:
		var button = Button.new()
		button.text = "Collect " + letter
		button.custom_minimum_size = Vector2(100, 30)
		button.pressed.connect(_on_debug_letter_toggled.bind(letter))
		debug_menu.add_child(button)
	
	var teleport_button = Button.new()
	teleport_button.text = "Teleport to Letter T"
	teleport_button.custom_minimum_size = Vector2(150, 30)
	teleport_button.pressed.connect(_on_debug_teleport_to_letter_t)
	debug_menu.add_child(teleport_button)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.custom_minimum_size = Vector2(100, 30)
	close_button.pressed.connect(_on_debug_menu_close)
	debug_menu.add_child(close_button)
	
	var hud_control = find_child("HUDControl")
	if hud_control:
		hud_control.add_child(debug_menu)
	else:
		add_child(debug_menu)
	
	debug_menu.visible = false

func _on_debug_letter_toggled(letter: String) -> void:
	var letter_item: PlayerInventory.Item
	match letter:
		"A":
			letter_item = PlayerInventory.Item.SECRET_LETTER_A
		"D":
			letter_item = PlayerInventory.Item.SECRET_LETTER_D
		"O":
			letter_item = PlayerInventory.Item.SECRET_LETTER_O
		"P":
			letter_item = PlayerInventory.Item.SECRET_LETTER_P
		"T":
			letter_item = PlayerInventory.Item.SECRET_LETTER_T
		"F":
			letter_item = PlayerInventory.Item.SECRET_LETTER_F
		"R":
			letter_item = PlayerInventory.Item.SECRET_LETTER_R
		"E":
			letter_item = PlayerInventory.Item.SECRET_LETTER_E
		"S":
			letter_item = PlayerInventory.Item.SECRET_LETTER_S
		"H":
			letter_item = PlayerInventory.Item.SECRET_LETTER_H
		_:
			return
	
	PlayerInventory.add_item(letter_item)
	GameState.add_collected_letter(letter)
	GlobalSignals.secret_letter_collected.emit(letter_item)

func _on_debug_menu_close() -> void:
	if debug_menu:
		debug_menu.visible = false

func _on_debug_teleport_to_letter_t() -> void:
	var chonki = get_tree().current_scene.find_child("Chonki", true, false)
	var marker = get_tree().current_scene.find_child("SkipLevelDebug", true, false)
	
	if not chonki:
		print("[DEBUG] ERROR: Could not find Chonki node")
		return
	
	if not marker:
		print("[DEBUG] ERROR: Could not find SkipLevelDebug marker")
		return
	
	chonki.global_position = marker.global_position
	print("[DEBUG] Teleported Chonki to SkipLevelDebug marker position: ", chonki.global_position)

func _on_star_collected() -> void:
	books_collected += 1
	GameState.stars_collected = books_collected

func _on_heart_lost() -> void:
	var current_hearts = PlayerInventory.get_total_hearts()
	var heart_node = find_child("Heart" + str(current_hearts + 1))
	if heart_node:
		heart_node.queue_free()

func _on_secret_letter_collected(letter_item: PlayerInventory.Item) -> void:
	var letter = GameState.get_letter_string_from_item(letter_item)
	_display_letter(letter)

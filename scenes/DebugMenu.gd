extends Control

@onready var debug_info_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DebugInfoLabel

func _ready():
	update_debug_info()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_dismiss_button_pressed()
		get_viewport().set_input_as_handled()

func update_debug_info() -> void:
	var info = []
	info.append("Level: %d" % GameState.current_level)
	info.append("Stars: %d" % GameState.stars_collected)
	info.append("Hearts: %d" % PlayerInventory.total_hearts)
	info.append("Letters: %d/5" % PlayerInventory.get_collected_secret_letter_count())
	
	debug_info_label.text = "\n".join(info)

func show_menu() -> void:
	visible = true
	update_debug_info()
	GlobalSignals.set_chonki_frozen.emit(true)

func hide_menu() -> void:
	visible = false
	GlobalSignals.set_chonki_frozen.emit(false)

func _on_restart_button_pressed() -> void:
	hide_menu()
	get_tree().reload_current_scene()

func _on_skip_button_pressed() -> void:
	hide_menu()
	if GameState.current_level == 1:
		SceneStack.push_scene(preload("res://scenes/level1.tscn"))
	elif GameState.current_level == 2:
		SceneStack.push_scene(preload("res://scenes/final_animation_sequence.tscn"))

func _on_dismiss_button_pressed() -> void:
	hide_menu()

func _on_add_letter_a_button_pressed() -> void:
	_add_letter(PlayerInventory.Item.SECRET_LETTER_A)

func _on_add_letter_d_button_pressed() -> void:
	_add_letter(PlayerInventory.Item.SECRET_LETTER_D)

func _on_add_letter_o_button_pressed() -> void:
	_add_letter(PlayerInventory.Item.SECRET_LETTER_O)

func _on_add_letter_p_button_pressed() -> void:
	_add_letter(PlayerInventory.Item.SECRET_LETTER_P)

func _on_add_letter_t_button_pressed() -> void:
	_add_letter(PlayerInventory.Item.SECRET_LETTER_T)

func _on_add_all_letters_button_pressed() -> void:
	if GameState.current_level == 1:
		_add_letter(PlayerInventory.Item.SECRET_LETTER_A)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_D)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_O)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_P)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_T)
	elif GameState.current_level == 2:
		_add_letter(PlayerInventory.Item.SECRET_LETTER_F)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_R)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_E)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_S)
		_add_letter(PlayerInventory.Item.SECRET_LETTER_H)

func _add_letter(letter_item: PlayerInventory.Item) -> void:
	var level = GameState.current_level
	if GameState.collected_letter_items_by_level.has(level):
		if letter_item not in GameState.collected_letter_items_by_level[level]:
			GameState.collected_letter_items_by_level[level].append(letter_item)
			var letter_string = GameState.get_letter_string_from_item(letter_item)
			GameState.add_collected_letter(letter_string)
			GlobalSignals.secret_letter_collected.emit(letter_item)
			PlayerInventory.increment_midair_jumps()
	update_debug_info()

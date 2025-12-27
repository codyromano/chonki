extends PanelContainer

@onready var label: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var dialogue_options_container: VBoxContainer = $VBoxContainer/VBoxContainer/DialogueOptions
@onready var typewriter: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var press_enter_label: Label = $VBoxContainer/VBoxContainer/PressEnterLabel

var dialogue: String = ""
var instruction_trigger_id: String = ""
var dialogue_option_scene: PackedScene = preload("res://scenes/menus/dialogue_option.tscn")
var continue_option_id: String = ""
var is_typewriter_active: bool = false
var skip_sound: AudioStreamPlayer

func _ready() -> void:
	if !label:
		push_error("[MainDialogueDisplay] ERROR: label is null!")
		return
	if !typewriter:
		push_error("[MainDialogueDisplay] ERROR: typewriter is null!")
		return
	if !dialogue_options_container:
		push_error("[MainDialogueDisplay] ERROR: dialogue_options_container is null!")
		return
	if !press_enter_label:
		push_error("[MainDialogueDisplay] ERROR: press_enter_label is null!")
		return
	
	label.text = dialogue
	
	dialogue_options_container.modulate.a = 0
	dialogue_options_container.hide()
	
	press_enter_label.modulate.a = 0
	press_enter_label.hide()
	
	for child in dialogue_options_container.get_children():
		child.queue_free()
	
	if typewriter:
		is_typewriter_active = true
		typewriter.animation_complete.connect(_on_typewriter_complete)
	
	skip_sound = AudioStreamPlayer.new()
	skip_sound.stream = load("res://assets/sound/book1.mp3")
	skip_sound.volume_db = 0.0
	add_child(skip_sound)

func set_instruction_trigger_id(trigger_id: String) -> void:
	instruction_trigger_id = trigger_id

func _on_typewriter_complete() -> void:
	is_typewriter_active = false
	var choices = MainDialogueController.get_dialogue_choices()
	
	if choices.size() == 1 and choices[0].text == "Continue":
		continue_option_id = choices[0].id
		_show_press_enter_label()
	elif choices.size() > 0:
		_create_dialogue_options(choices)

func _show_press_enter_label() -> void:
	press_enter_label.show()
	
	var tween = create_tween()
	tween.tween_property(press_enter_label, "modulate:a", 1.0, 0.5)

func _create_dialogue_options(choices: Array) -> void:
	dialogue_options_container.show()
	
	var option_buttons: Array[Button] = []
	
	# Create a button for each choice
	for i in range(choices.size()):
		var choice = choices[i]
		var option_button = dialogue_option_scene.instantiate()
		dialogue_options_container.add_child(option_button)
		
		# Setup the option with id and text
		if option_button.has_method("setup"):
			option_button.setup(choice.id, choice.text)
		
		option_buttons.append(option_button)
	
	# Configure focus neighbors for navigation
	for i in range(option_buttons.size()):
		var current_button = option_buttons[i]
		
		# Set up neighbor
		if i > 0:
			current_button.focus_neighbor_top = current_button.get_path_to(option_buttons[i - 1])
		
		# Set down neighbor
		if i < option_buttons.size() - 1:
			current_button.focus_neighbor_bottom = current_button.get_path_to(option_buttons[i + 1])
	
	# Fade in the options container over 0.5 seconds
	var tween = create_tween()
	tween.tween_property(dialogue_options_container, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# Auto-focus the first option
	if option_buttons.size() > 0:
		option_buttons[0].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if !event.is_action_pressed("ui_accept"):
		return
	
	if is_typewriter_active and typewriter and typewriter.has_method("is_typing") and typewriter.is_typing():
		typewriter.skip_to_end()
		if skip_sound:
			skip_sound.play()
		get_viewport().set_input_as_handled()
	elif continue_option_id != "" and press_enter_label.modulate.a >= 1.0:
		GlobalSignals.dialogue_option_selected.emit(continue_option_id, "Continue")
		get_viewport().set_input_as_handled()
	elif dialogue_options_container.modulate.a < 1.0 and !is_typewriter_active:
		GlobalSignals.dismiss_active_main_dialogue.emit(instruction_trigger_id)
		get_viewport().set_input_as_handled()

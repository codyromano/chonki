extends PanelContainer

@onready var label: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var dialogue_options_container: VBoxContainer = $VBoxContainer/VBoxContainer/DialogueOptions
@onready var typewriter: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var avatar: TextureRect = $VBoxContainer/HBoxContainer/Avatar
@onready var press_enter_label: Label = find_child('PressEnterLabel')

var dialogue_options_count: int = 0
var is_typewriter_active: bool = true

var can_dismiss_dialogue: bool = false
var is_dismissing: bool = false

func _ready():
	# Check all required nodes
	if !label:
		push_error("[MainDialogueDisplay] label is null! Node path: $VBoxContainer/HBoxContainer/TypewriterReveal")
		return
	
	if !typewriter:
		push_error("[MainDialogueDisplay] typewriter is null! Node path: $VBoxContainer/HBoxContainer/TypewriterReveal")
		return
	
	if !dialogue_options_container:
		push_error("[MainDialogueDisplay] dialogue_options_container is null! Node path: $VBoxContainer/VBoxContainer/DialogueOptions")
		return
	
	# Make sure options container is hidden initially
	dialogue_options_container.visible = false
	
	# Connect to typewriter animation complete
	if typewriter.animation_complete.connect(_on_typewriter_complete) != OK:
		push_error("[MainDialogueDisplay] Failed to connect to typewriter animation_complete signal")

func set_dialogue(text: String) -> void:
	if typewriter:
		typewriter.text_after_reveal = text
	else:
		push_error("[MainDialogueDisplay] Cannot set dialogue, typewriter is null")

func set_avatar(texture: CompressedTexture2D) -> void:
	if avatar:
		avatar.texture = texture
	else:
		push_error("[MainDialogueDisplay] Cannot set avatar, avatar node is null")

func _on_typewriter_complete() -> void:
	is_typewriter_active = false
	
	var choices = MainDialogueController.get_dialogue_choices()
	
	if choices.size() > 0:
		_create_dialogue_options(choices)
	else:
		can_dismiss_dialogue = true

func _create_dialogue_options(choices: Array) -> void:
	for child in dialogue_options_container.get_children():
		if child.name.begins_with("DialogueOption"):
			child.queue_free()
	
	var option_scene = preload("res://scenes/menus/dialogue_option.tscn")
	var option_buttons: Array[Button] = []
	
	for i in range(choices.size()):
		var choice = choices[i]
		
		var option_instance = option_scene.instantiate()
		dialogue_options_container.add_child(option_instance)
		option_instance.setup(choice.id, choice.text)
		option_instance.focus_mode = Control.FOCUS_ALL
		option_buttons.append(option_instance)
	
	for i in range(option_buttons.size()):
		var current_button = option_buttons[i]
		
		if i > 0:
			current_button.focus_neighbor_top = current_button.get_path_to(option_buttons[i - 1])
		
		if i < option_buttons.size() - 1:
			current_button.focus_neighbor_bottom = current_button.get_path_to(option_buttons[i + 1])
	
	dialogue_options_container.visible = true
	
	call_deferred("_focus_first_option")
	
	dialogue_options_count = choices.size()

func _focus_first_option() -> void:
	await get_tree().process_frame
	
	if dialogue_options_container.get_child_count() > 0:
		for child in dialogue_options_container.get_children():
			if child is Button and child.visible:
				child.grab_focus()
				break

func _process(_delta) -> void:
	press_enter_label.visible = dialogue_options_count == 0 && !is_typewriter_active

func _unhandled_input(event: InputEvent) -> void:
	if dialogue_options_container.visible and dialogue_options_count > 0:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			return
	
	if is_dismissing or !can_dismiss_dialogue:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up"):
		is_dismissing = true
		GlobalSignals.dismiss_active_main_dialogue.emit("")
		
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()

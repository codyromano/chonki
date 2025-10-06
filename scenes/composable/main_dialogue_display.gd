extends PanelContainer

@onready var label: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var dialogue_options_container: VBoxContainer = $VBoxContainer/VBoxContainer/DialogueOptions
@onready var typewriter: Label = $VBoxContainer/HBoxContainer/TypewriterReveal

var dialogue: String = ""
var instruction_trigger_id: String = ""
var dialogue_option_scene: PackedScene = preload("res://scenes/menus/dialogue_option.tscn")

func _ready() -> void:
	print("==========================================")
	print("=== MainDialogueDisplay _ready START ===")
	print("==========================================")
	print("[MainDialogueDisplay] _ready called. Instance: ", self)
	print("[MainDialogueDisplay] Dialogue text: '", dialogue, "'")
	print("[MainDialogueDisplay] Label node: ", label)
	print("[MainDialogueDisplay] Typewriter node: ", typewriter)
	print("[MainDialogueDisplay] Options container: ", dialogue_options_container)
	
	if !label:
		push_error("[MainDialogueDisplay] ERROR: label is null!")
		return
	if !typewriter:
		push_error("[MainDialogueDisplay] ERROR: typewriter is null!")
		return
	if !dialogue_options_container:
		push_error("[MainDialogueDisplay] ERROR: dialogue_options_container is null!")
		return
	
	label.text = dialogue
	print("[MainDialogueDisplay] Set label.text to: '", dialogue, "'")
	
	# Hide dialogue options initially
	dialogue_options_container.modulate.a = 0
	dialogue_options_container.hide()
	
	# Clear any existing placeholder options
	var placeholder_count = dialogue_options_container.get_child_count()
	print("[MainDialogueDisplay] Clearing ", placeholder_count, " placeholder options")
	for child in dialogue_options_container.get_children():
		child.queue_free()
	
	# Connect to typewriter animation complete signal
	if typewriter:
		print("[MainDialogueDisplay] Connecting to typewriter animation_complete signal")
		typewriter.animation_complete.connect(_on_typewriter_complete)
		print("[MainDialogueDisplay] Successfully connected to animation_complete")
	else:
		print("[MainDialogueDisplay] WARNING: No typewriter found!")

func set_instruction_trigger_id(trigger_id: String) -> void:
	instruction_trigger_id = trigger_id

func _on_typewriter_complete() -> void:
	print("[MainDialogueDisplay] Typewriter animation complete")
	
	var choices = MainDialogueController.get_dialogue_choices()
	print("[MainDialogueDisplay] Retrieved ", choices.size(), " choices from controller")
	
	if choices.size() > 0:
		print("[MainDialogueDisplay] Creating dialogue options...")
		_create_dialogue_options(choices)
	else:
		print("[MainDialogueDisplay] No choices to display")

func _create_dialogue_options(choices: Array) -> void:
	print("[MainDialogueDisplay] _create_dialogue_options called")
	dialogue_options_container.show()
	print("[MainDialogueDisplay] Container shown")
	
	var option_buttons: Array[Button] = []
	
	# Create a button for each choice
	print("[MainDialogueDisplay] Creating ", choices.size(), " option buttons")
	for i in range(choices.size()):
		var choice = choices[i]
		print("[MainDialogueDisplay] Creating option ", i, ": ", choice)
		var option_button = dialogue_option_scene.instantiate()
		print("[MainDialogueDisplay] Option button instantiated: ", option_button)
		dialogue_options_container.add_child(option_button)
		print("[MainDialogueDisplay] Option button added to container")
		
		# Setup the option with id and text
		if option_button.has_method("setup"):
			print("[MainDialogueDisplay] Calling setup with id=", choice.id, " text=", choice.text)
			option_button.setup(choice.id, choice.text)
		else:
			print("[MainDialogueDisplay] WARNING: option_button does not have setup method!")
		
		option_buttons.append(option_button)
	
	# Configure focus neighbors for navigation
	print("[MainDialogueDisplay] Configuring focus neighbors for ", option_buttons.size(), " buttons")
	for i in range(option_buttons.size()):
		var current_button = option_buttons[i]
		
		# Set up neighbor
		if i > 0:
			current_button.focus_neighbor_top = current_button.get_path_to(option_buttons[i - 1])
		
		# Set down neighbor
		if i < option_buttons.size() - 1:
			current_button.focus_neighbor_bottom = current_button.get_path_to(option_buttons[i + 1])
	
	# Fade in the options container over 0.5 seconds
	print("[MainDialogueDisplay] Starting fade-in animation")
	var tween = create_tween()
	tween.tween_property(dialogue_options_container, "modulate:a", 1.0, 0.5)
	await tween.finished
	print("[MainDialogueDisplay] Fade-in complete")
	
	# Auto-focus the first option
	if option_buttons.size() > 0:
		print("[MainDialogueDisplay] Auto-focusing first option")
		option_buttons[0].grab_focus()
	else:
		print("[MainDialogueDisplay] WARNING: No option buttons to focus!")

func _unhandled_input(event: InputEvent) -> void:
	# Only handle dismiss if there are no dialogue options showing
	if dialogue_options_container.modulate.a < 1.0:
		if event.is_action_pressed("read") or event.is_action_pressed("jump"):
			GlobalSignals.dismiss_active_main_dialogue.emit(instruction_trigger_id)
			# Stop the event from propagating further and prevent multiple dismissals.
			get_viewport().set_input_as_handled()

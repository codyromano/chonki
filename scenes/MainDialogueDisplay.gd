extends PanelContainer

@onready var label: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var dialogue_options_container: VBoxContainer = $VBoxContainer/VBoxContainer/DialogueOptions
@onready var typewriter: Label = $VBoxContainer/HBoxContainer/TypewriterReveal
@onready var avatar: TextureRect = $VBoxContainer/HBoxContainer/Avatar

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
	# Get choices from MainDialogueController singleton
	var choices = MainDialogueController.get_dialogue_choices()
	
	if choices.size() > 0:
		_create_dialogue_options(choices)
	else:
		can_dismiss_dialogue = true

func _create_dialogue_options(choices: Array) -> void:
	# Clear any existing options
	for child in dialogue_options_container.get_children():
		if child.name.begins_with("DialogueOption"):
			child.queue_free()
	
	# Create option buttons
	var option_scene = preload("res://scenes/menus/dialogue_option.tscn")
	
	for i in range(choices.size()):
		var choice = choices[i]
		
		var option_instance = option_scene.instantiate()
		dialogue_options_container.add_child(option_instance)
		option_instance.setup(choice.id, choice.text)
	
	# Show the options container
	dialogue_options_container.visible = true
	
	# Focus the first option
	if dialogue_options_container.get_child_count() > 0:
		var first_option = dialogue_options_container.get_child(0)
		first_option.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	print("[MainDialogueDisplay] _unhandled_input called, is_dismissing=", is_dismissing, " can_dismiss=", can_dismiss_dialogue)
	
	# Don't handle input if we're already dismissing or can't dismiss
	if is_dismissing or !can_dismiss_dialogue:
		return
		
	if event.is_action_pressed("read") or event.is_action_pressed("jump"):
		print("[MainDialogueDisplay] Emitting dismiss signal")
		is_dismissing = true
		GlobalSignals.dismiss_active_main_dialogue.emit("")
		# Stop the event from propagating further and prevent multiple dismissals.
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()

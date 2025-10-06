extends Node

var dialogue_queue: Array = []

@export var duration_per_character: float = 0.075
var dialogue_scene: PackedScene = preload("res://scenes/composable/main_dialogue_display.tscn")
var canvas_layer: CanvasLayer = null

var time_dialogue_created: float
var rendered_dialogue: PanelContainer
var current_instruction_trigger_id: String = ""
var is_ready: bool = false
var can_dismiss_dialogue: bool = false
var current_dialogue_choices: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	GlobalSignals.queue_main_dialogue.connect(_on_dialogue_queued)
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dismiss_active_dialogue)
	
	# Configure all audio players to continue playing during dialogue pause
	_configure_audio_players_for_dialogue()

	is_ready = true

func _get_canvas_layer() -> CanvasLayer:
	# Lazy-load the canvas layer from the current scene
	if !canvas_layer or !is_instance_valid(canvas_layer):
		var current_scene = get_tree().current_scene
		if current_scene:
			# Look for a CanvasLayer that contains MainDialogueController or TitleCanvasLayer
			canvas_layer = _find_canvas_layer(current_scene)
			if canvas_layer:
				canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	return canvas_layer

func _find_canvas_layer(node: Node) -> CanvasLayer:
	# Check if node is a CanvasLayer
	if node is CanvasLayer:
		return node
	
	# Check children
	for child in node.get_children():
		if child is CanvasLayer:
			return child
		var result = _find_canvas_layer(child)
		if result:
			return result
	
	return null


func _configure_audio_players_for_dialogue() -> void:
	# Find all AudioStreamPlayer and AudioStreamPlayer2D nodes and configure them
	# to continue playing during dialogue pauses
	var current_scene = get_tree().current_scene
	if current_scene:
		var audio_nodes = _find_all_audio_nodes(current_scene)
		for audio_node in audio_nodes:
			audio_node.process_mode = Node.PROCESS_MODE_ALWAYS


func _find_all_audio_nodes(node: Node) -> Array:
	var audio_nodes = []
	
	# Check if current node is an audio player
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		audio_nodes.append(node)
	
	# Recursively check all children
	for child in node.get_children():
		audio_nodes.append_array(_find_all_audio_nodes(child))
	
	return audio_nodes


func _process(_delta: float) -> void:	
	if is_ready and rendered_dialogue and can_dismiss_dialogue and (Input.is_action_just_pressed("read") or Input.is_action_just_pressed("jump")):
		GlobalSignals.dismiss_active_main_dialogue.emit(current_instruction_trigger_id)


func _create_dialogue(dialogue: String, trigger_id: String = "", avatar_name: String = "", choices: Array = []) -> PanelContainer:
	current_dialogue_choices = choices
	
	var target_canvas_layer = _get_canvas_layer()
	if !target_canvas_layer:
		push_error("[MainDialogueController] No CanvasLayer found to display dialogue!")
		return null
	
	var scene = dialogue_scene.instantiate()
	target_canvas_layer.call_deferred("add_child", scene)
	# Set dialogue text using the method after scene is added to tree
	scene.call_deferred("set_dialogue", dialogue)
	# Set avatar if provided
	if avatar_name != "":
		var avatar_texture = get_avatar_texture(avatar_name)
		scene.call_deferred("set_avatar", avatar_texture)
	
	time_dialogue_created = Time.get_unix_time_from_system()
	
	# Prevent immediate dismissal by waiting one frame
	can_dismiss_dialogue = false
	await get_tree().process_frame
	can_dismiss_dialogue = true
	
	return scene


func _process_queue() -> void:
	if not is_inside_tree():
		return
	
	var tree = get_tree()
	if not tree:
		return
	
	if rendered_dialogue:
		rendered_dialogue.queue_free()
		rendered_dialogue = null

	if dialogue_queue.is_empty():
		tree.paused = false
		current_instruction_trigger_id = ""
		return

	var next_dialogue_data = dialogue_queue.pop_front()
	var dialogue_text = next_dialogue_data.dialogue if next_dialogue_data is Dictionary else next_dialogue_data
	current_instruction_trigger_id = next_dialogue_data.trigger_id if next_dialogue_data is Dictionary else ""
	var avatar_name = next_dialogue_data.avatar_name if next_dialogue_data.has("avatar_name") else ""
	var choices = next_dialogue_data.choices if next_dialogue_data.has("choices") else []
	rendered_dialogue = await _create_dialogue(dialogue_text, current_instruction_trigger_id, avatar_name, choices)
	
	tree.paused = true


func _on_dialogue_queued(dialogue: String, instruction_trigger_id: String = "", avatar_name: String = "", choices: Array = []) -> void:
	var dialogue_data = {
		"dialogue": dialogue,
		"trigger_id": instruction_trigger_id,
		"avatar_name": avatar_name,
		"choices": choices
	}
	dialogue_queue.push_back(dialogue_data)
	if not rendered_dialogue:
		_process_queue()


func _on_dismiss_active_dialogue(_instruction_trigger_id: String) -> void:
	_process_queue()

func get_dialogue_choices() -> Array:
	return current_dialogue_choices


# Returns a CompressedTexture2D for the given avatar name, or null if not found
func get_avatar_texture(avatar_name: String) -> CompressedTexture2D:
	match avatar_name:
		"gus":
			return load("res://assets/avatar/avatar-gus.png")
		# Add more avatar mappings here as needed
		"momo":
			return load("res://assets/avatar/avatar-momo.png")
		_:
			return null

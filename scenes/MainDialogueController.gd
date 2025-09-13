extends Node2D

var dialogue_queue: Array = []

@export var duration_per_character: float = 0.075
@onready var dialogue_scene: PackedScene = preload("res://scenes/composable/main_dialogue_display.tscn")
@onready var canvas_layer: CanvasLayer = get_parent()

var rendered_dialogue: PanelContainer
var is_ready: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	GlobalSignals.queue_main_dialogue.connect(_on_dialogue_queued)
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dismiss_active_dialogue)
	
	# Configure all audio players to continue playing during dialogue pause
	_configure_audio_players_for_dialogue()

	var current_scene = get_tree().current_scene
	if current_scene && current_scene.name == 'Intro':
		await get_tree().create_timer(1.0).timeout
		_on_dialogue_queued("Today is a big day! I'd better find a way out of this barn...")

	await get_tree().create_timer(0.2).timeout
	is_ready = true


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
	if is_ready and rendered_dialogue and (Input.is_action_just_pressed("read") or Input.is_action_just_pressed("jump")):
		GlobalSignals.dismiss_active_main_dialogue.emit()


func _create_dialogue(dialogue: String) -> PanelContainer:
	var scene = dialogue_scene.instantiate()
	scene.dialogue = dialogue
	scene.duration = float(dialogue.length()) * 0.025
	canvas_layer.call_deferred("add_child", scene)
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
		return

	var next_dialogue = dialogue_queue.pop_front()
	rendered_dialogue = _create_dialogue(next_dialogue)
	
	tree.paused = true


func _on_dialogue_queued(dialogue: String) -> void:
	dialogue_queue.push_back(dialogue)
	if not rendered_dialogue:
		_process_queue()


func _on_dismiss_active_dialogue() -> void:
	_process_queue()


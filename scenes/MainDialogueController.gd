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

	var current_scene = get_tree().current_scene
	if current_scene && current_scene.name == 'Intro':
		await get_tree().create_timer(2.0).timeout
		_on_dialogue_queued("*Yawn* That was a long nap!")
		_on_dialogue_queued("Today is a big day! I'd better find a way out of this barn...")

	await get_tree().create_timer(0.2).timeout
	is_ready = true


func _process(_delta: float) -> void:
	if is_ready and rendered_dialogue and Input.is_action_just_pressed("read"):
		GlobalSignals.dismiss_active_main_dialogue.emit()


func _create_dialogue(dialogue: String) -> PanelContainer:
	var scene = dialogue_scene.instantiate()
	scene.dialogue = dialogue
	scene.duration = dialogue.length() * duration_per_character
	canvas_layer.call_deferred("add_child", scene)
	return scene


func _process_queue() -> void:
	var tree = get_tree()
	if rendered_dialogue:
		rendered_dialogue.queue_free()
		rendered_dialogue = null

	if dialogue_queue.is_empty():
		if tree:
			tree.paused = false
		return

	var next_dialogue = dialogue_queue.pop_front()
	rendered_dialogue = _create_dialogue(next_dialogue)
	
	if tree:
		tree.paused = true


func _on_dialogue_queued(dialogue: String) -> void:
	dialogue_queue.push_back(dialogue)
	if not rendered_dialogue:
		_process_queue()


func _on_dismiss_active_dialogue() -> void:
	_process_queue()


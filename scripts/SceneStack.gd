extends Node

## Optional: set a hard cap to avoid hoarding memory with deep stacks.
@export var max_cached_scenes: int = 8

var _stack: Array[Node] = []
var _root: Node

func _ready() -> void:
	_root = get_tree().root

## Push a new scene from a PackedScene, caching the current one.
func push_scene(packed: PackedScene) -> Node:
	var current := get_tree().current_scene
	if current:
		# Stop current scene and detach it from the tree (preserves all state).
		current.visible = false
		current.process_mode = Node.PROCESS_MODE_DISABLED
		_root.remove_child(current)
		_stack.push_back(current)
		_prune_cache_if_needed()

	var next := packed.instantiate()
	_root.add_child(next)
	get_tree().current_scene = next
	# Ensure the new scene runs.
	next.visible = true
	next.process_mode = Node.PROCESS_MODE_INHERIT
	return next

## Push an already-instantiated scene (useful if you prebuilt it elsewhere).
func push_existing(next: Node) -> void:
	var current := get_tree().current_scene
	if current:
		current.visible = false
		current.process_mode = Node.PROCESS_MODE_DISABLED
		_root.remove_child(current)
		_stack.push_back(current)
		_prune_cache_if_needed()

	_root.add_child(next)
	get_tree().current_scene = next
	next.visible = true
	next.process_mode = Node.PROCESS_MODE_INHERIT

## Pop back to the previous scene, freeing the current one by default.
func pop_scene(free_current: bool = true) -> void:
	var current := get_tree().current_scene
	if current:
		_root.remove_child(current)
		if free_current:
			current.queue_free()

	if _stack.is_empty():
		push_warning("SceneStack is empty; nothing to pop to.")
		return

	var previous: Node = _stack.pop_back()
	_root.add_child(previous)
	get_tree().current_scene = previous
	previous.visible = true
	previous.process_mode = Node.PROCESS_MODE_INHERIT
	
	# If the restored scene has a scene transition controller, clear any fade overlay
	for child in previous.get_children():
		if child.has_method("clear_fade"):
			child.clear_fade()
			break

## Convenience: clear all cached scenes (e.g., when returning to main menu).
func clear_cache(free_scenes: bool = true) -> void:
	while not _stack.is_empty():
		var scene: Node = _stack.pop_back()
		if free_scenes:
			scene.queue_free()

func _prune_cache_if_needed() -> void:
	if max_cached_scenes > 0 and _stack.size() > max_cached_scenes:
		var old: Node = _stack.pop_front()
		old.queue_free()

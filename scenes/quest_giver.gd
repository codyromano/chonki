extends Node2D

@export var frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)
@export var avatar_name: String

# TODO: The quest_giver.gd should not have character-specific logic. This should be refactored
# and maybe put into an extension of quest_giver.gd. 
@export var rodrigo: Area2D

@onready var sprite: AnimatedSprite2D = find_child('QuestGiverSprite2D')
@onready var collision_shape: CollisionShape2D = find_child('QuestGiverCollisionShape')
@onready var instructions: Label = find_child('Instructions')
@onready var rodrigo_marker: Marker2D = find_child('RodrigoReturnedToIsaacMarker2D')

var tween_instructions: Tween

var is_player_nearby: bool = false
var can_trigger_dialogue: bool = true
var waiting_for_key_release: bool = false
var current_dialogue_node: DialogueNode = null
var is_in_dialogue: bool = false
var is_transitioning_dialogue: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite.sprite_frames = frames
	sprite.scale *= sprite_scale
	_prepare_collisions()
	
	# Listen for dialogue dismissal to prevent immediate re-trigger
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dialogue_dismissed)
	# Listen for dialogue option selection to progress through our dialogue tree
	GlobalSignals.dialogue_option_selected.connect(_on_dialogue_option_selected)
	update_rodrigo_position()
	
func update_rodrigo_position() -> void:
	if rodrigo:
		rodrigo.global_position = rodrigo_marker.global_position

func _process(_delta) -> void:
	# Check if we're waiting for key release and the key is now released
	if waiting_for_key_release and !Input.is_action_pressed("ui_accept"):
		print("[QuestGiver] Key released, allowing dialogue trigger")
		waiting_for_key_release = false
		can_trigger_dialogue = true
	
	update_rodrigo_position()

func _unhandled_input(event: InputEvent) -> void:
	# Don't process input if main dialogue is already showing (not from us)
	if MainDialogueController.rendered_dialogue and not is_in_dialogue:
		print("[QuestGiver] Input blocked: Another dialogue is showing")
		return
	
	# Only allow initiating dialogue when we can trigger and not waiting for key release
	if event.is_action_pressed("ui_accept"):
		print("[QuestGiver] Enter pressed in _unhandled_input")
		print("[QuestGiver]   is_player_nearby: ", is_player_nearby)
		print("[QuestGiver]   can_trigger_dialogue: ", can_trigger_dialogue)
		print("[QuestGiver]   waiting_for_key_release: ", waiting_for_key_release)
		print("[QuestGiver]   is_in_dialogue: ", is_in_dialogue)
		
		if is_player_nearby && can_trigger_dialogue && !waiting_for_key_release:
			print("[QuestGiver] All conditions met! Initiating dialogue")
			can_trigger_dialogue = false
			_initiate_dialogue()
			get_viewport().set_input_as_handled()
		else:
			print("[QuestGiver] Conditions NOT met, dialogue will not trigger")

func _on_dialogue_dismissed(_instruction_trigger_id: String) -> void:
	print("[QuestGiver] _on_dialogue_dismissed called")
	print("[QuestGiver] is_in_dialogue: ", is_in_dialogue)
	print("[QuestGiver] is_transitioning_dialogue: ", is_transitioning_dialogue)
	print("[QuestGiver] current_dialogue_node: ", current_dialogue_node)
	if current_dialogue_node:
		print("[QuestGiver] current_dialogue_node.choices.size(): ", current_dialogue_node.choices.size())
	
	# If we're transitioning between dialogue nodes, don't end the dialogue
	if is_transitioning_dialogue:
		print("[QuestGiver] Transitioning, not ending dialogue")
		is_transitioning_dialogue = false
		return
	
	# If we're in dialogue, always clean up state when dismissed
	if is_in_dialogue:
		print("[QuestGiver] Ending dialogue, resetting state")
		is_in_dialogue = false
		waiting_for_key_release = true
		
		# Only call on_dialogue_finished and reset if we're at a leaf node (no more choices)
		if current_dialogue_node and current_dialogue_node.choices.size() == 0:
			print("[QuestGiver] At leaf node, calling on_dialogue_finished")
			on_dialogue_finished()
			current_dialogue_node = null
		else:
			print("[QuestGiver] Not at leaf node, keeping current_dialogue_node for next interaction")
	else:
		print("[QuestGiver] Not in dialogue, ignoring dismiss")

func _on_dialogue_option_selected(option_id: String, _option_text: String) -> void:
	# Only handle this if we're currently in dialogue with this quest giver
	if !is_in_dialogue:
		return
	
	# Find the next node based on the selected option
	var next_node = get_next_dialogue_node_custom(current_dialogue_node, option_id)
	if next_node:
		current_dialogue_node = next_node
		# Mark that we're transitioning so _on_dialogue_dismissed doesn't end dialogue
		is_transitioning_dialogue = true
		# Dismiss the current dialogue first
		GlobalSignals.dismiss_active_main_dialogue.emit("")
		# Wait a frame before displaying the next node to ensure the current dialogue is dismissed
		await get_tree().process_frame
		_display_current_node()
	else:
		# No next node, end the dialogue
		GlobalSignals.dismiss_active_main_dialogue.emit("")
		is_in_dialogue = false
	# Warnings are already handled in get_next_dialogue_node()

func _initiate_dialogue() -> void:
	print("[QuestGiver] _initiate_dialogue called")
	# Hide instructions when dialogue starts
	_set_instructions_opacity(0, 0.25)
	
	# If we don't have a current node, start from the root
	if !current_dialogue_node:
		print("[QuestGiver] No current node, getting dialogue tree root")
		var dialogue_tree = _get_dialogue_tree()
		if dialogue_tree and dialogue_tree.root_node:
			current_dialogue_node = dialogue_tree.root_node
		else:
			push_error("Quest giver has no valid dialogue tree")
			return
	
	# Display the current node (either root on first interaction, or last leaf node on subsequent interactions)
	print("[QuestGiver] Setting is_in_dialogue = true")
	is_in_dialogue = true
	_display_current_node()

func _display_current_node() -> void:
	if !current_dialogue_node:
		push_error("Cannot display dialogue: current_dialogue_node is null")
		return
	
	var text: String = current_dialogue_node.text
	var choices = current_dialogue_node.choices if (current_dialogue_node.choices != null and current_dialogue_node.choices.size() > 0) else []
	GlobalSignals.queue_main_dialogue.emit(text, "", avatar_name, choices)

# Override this method in child classes to handle when all dialogue is finished
func on_dialogue_finished() -> void:
	pass

# Reset dialogue state (e.g., when quest completes)
func reset_dialogue() -> void:
	current_dialogue_node = null

# Utility function to get the next dialogue node based on a choice
# Returns the next_node for the matching option_id, or null if not found
func get_next_dialogue_node(start_node: DialogueNode, option_id: String) -> DialogueNode:
	if !start_node:
		return null
	
	# Find the next node based on the selected option
	if start_node.choices:
		for choice in start_node.choices:
			if choice.id == option_id:
				# Return the next node
				if choice.has("next_node"):
					return choice.next_node
				else:
					push_warning("Selected dialogue option has no next_node: " + option_id)
					return null
		push_warning("Could not find dialogue choice with id: " + option_id)
	
	return null

# This is designed to be overridden by character-specific quest givers.
# This base class returns the next node in the dialogue tree by default. 
# However, characters can apply their own logic - for example, only proceed
# to the next node if [some story condition] has been met.
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	return get_next_dialogue_node(current_node, selected_option_id)
	

func _get_dialogue_tree() -> DialogueTree:
	var dialogue_tree = DialogueTree.new()
	var placeholder_node = DialogueNode.new()
	placeholder_node.text = "Placeholder"
	placeholder_node.choices = []
	
	dialogue_tree.root_node = placeholder_node
	push_warning("Using dummy dialogue tree because quest giver hasn't implemented one")
	return dialogue_tree

func _prepare_collisions() -> void:
		collision_shape.position = sprite.position
		collision_shape.scale = sprite.scale

		var sprite_frames = sprite.get_sprite_frames()
		if not sprite_frames or not sprite.animation:
			push_error("Expected quest giver to have sprite frames")
			return
			
		var tex = sprite_frames.get_frame_texture(sprite.animation, 0)
		if tex and collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape
			rect_shape.size = tex.get_size() * sprite.scale

func _set_instructions_opacity(modulate_a: float, duration: float) -> void:
		if tween_instructions:
			tween_instructions.kill()
			
		tween_instructions = create_tween()
		tween_instructions.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween_instructions.tween_property(instructions, "modulate:a", modulate_a, duration)
		await tween_instructions.finished

# Override this in character-specific quest giver scripts to
# listen to collision events (e.g. Ruby's volleyball being returned)
func _on_body_entered_override(_body: Node2D) -> void:
	pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_player_nearby = true
		_set_instructions_opacity(1, 0.25)
	
	_on_body_entered_override(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_player_nearby = false
		_set_instructions_opacity(0, 1)

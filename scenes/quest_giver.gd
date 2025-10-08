extends Node2D

@export var frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)
@export var avatar_name: String

@onready var sprite: AnimatedSprite2D = find_child('QuestGiverSprite2D')
@onready var collision_shape: CollisionShape2D = find_child('QuestGiverCollisionShape')
@onready var instructions: Label = find_child('Instructions')

var tween_instructions: Tween

var is_player_nearby: bool = false
var can_trigger_dialogue: bool = true
var waiting_for_key_release: bool = false
var current_dialogue_node: DialogueNode = null
var is_in_dialogue: bool = false

func _ready() -> void:
	sprite.sprite_frames = frames
	sprite.scale *= sprite_scale
	_prepare_collisions()
	
	# Listen for dialogue dismissal to prevent immediate re-trigger
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dialogue_dismissed)
	# Listen for dialogue option selection to progress through our dialogue tree
	GlobalSignals.dialogue_option_selected.connect(_on_dialogue_option_selected)

func _process(_delta) -> void:  
	# Check if we're waiting for key release and the key is now released
	if waiting_for_key_release and !Input.is_action_pressed("read"):
		waiting_for_key_release = false
		can_trigger_dialogue = true
	
	# Only allow initiating dialogue when we can trigger and not waiting for key release
	if Input.is_action_just_pressed("read") && is_player_nearby && can_trigger_dialogue && !waiting_for_key_release:
		can_trigger_dialogue = false
		_initiate_dialogue()

func _on_dialogue_dismissed(_instruction_trigger_id: String) -> void:
	# Mark that we're waiting for the read key to be released before allowing re-trigger
	waiting_for_key_release = true
	is_in_dialogue = false

func _on_dialogue_option_selected(option_id: String, _option_text: String) -> void:
	# Only handle this if we're currently in dialogue with this quest giver
	if !is_in_dialogue:
		return
	
	# Dismiss the current dialogue first
	GlobalSignals.dismiss_active_main_dialogue.emit("")
	
	# Find the next node based on the selected option
	var next_node = get_next_dialogue_node_custom(current_dialogue_node, option_id)
	if next_node:
		current_dialogue_node = next_node
		# Wait a frame before displaying the next node to ensure the current dialogue is dismissed
		await get_tree().process_frame
		_display_current_node()
	# Warnings are already handled in get_next_dialogue_node()

func _initiate_dialogue() -> void:
	# Hide instructions when dialogue starts
	_set_instructions_opacity(0, 0.25)
	
	# If we don't have a current node, start from the root
	if !current_dialogue_node:
		var dialogue_tree = _get_dialogue_tree()
		if dialogue_tree and dialogue_tree.root_node:
			current_dialogue_node = dialogue_tree.root_node
		else:
			push_error("Quest giver has no valid dialogue tree")
			return
	
	# Display the current node (either root on first interaction, or last leaf node on subsequent interactions)
	is_in_dialogue = true
	_display_current_node()

func _display_current_node() -> void:
	if !current_dialogue_node:
		push_error("Cannot display dialogue: current_dialogue_node is null")
		return
	
	var text: String = current_dialogue_node.text
	var choices = current_dialogue_node.choices if (current_dialogue_node.choices != null and current_dialogue_node.choices.size() > 0) else []
	GlobalSignals.queue_main_dialogue.emit(text, "", avatar_name, choices)

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
		# Overlay the collision shape onto the sprite
		collision_shape.position = sprite.position
		collision_shape.scale = sprite.scale

		# Update the shape property to match the sprite's size
		var tex = sprite.get_sprite_frames().get_frame_texture(sprite.animation, 0)
		if tex and collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape
			rect_shape.size = tex.get_size() * sprite.scale

func _set_instructions_opacity(modulate_a: float, duration: float) -> void:
		if tween_instructions:
			tween_instructions.kill()
			
		tween_instructions = create_tween()
		tween_instructions.tween_property(instructions, "modulate:a", modulate_a, duration)
		await tween_instructions.finished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_player_nearby = true
		_set_instructions_opacity(1, 0.25)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_player_nearby = false
		_set_instructions_opacity(0, 1)

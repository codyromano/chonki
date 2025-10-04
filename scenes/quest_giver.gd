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

func _ready() -> void:
	sprite.sprite_frames = frames
	sprite.scale *= sprite_scale
	_prepare_collisions()
	
	# Listen for dialogue dismissal to prevent immediate re-trigger
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dialogue_dismissed)

func _process(_delta) -> void:
	# Check if we're waiting for key release and the key is now released
	if waiting_for_key_release and !Input.is_action_pressed("read"):
		waiting_for_key_release = false
		can_trigger_dialogue = true
	
	# Only allow initiating dialogue when game is not paused and we can trigger
	if Input.is_action_just_pressed("read") && is_player_nearby && !get_tree().paused && can_trigger_dialogue:
		can_trigger_dialogue = false
		_initiate_dialogue()

func _on_dialogue_dismissed(_instruction_trigger_id: String) -> void:
	# Mark that we're waiting for the read key to be released before allowing re-trigger
	waiting_for_key_release = true

func _initiate_dialogue() -> void:
	# Display the current dialogue from the character's dialogue tree
	var relevant_text: String = _get_dialogue_tree().root_node.text
	print("should display dialogue: " + relevant_text)
	GlobalSignals.queue_main_dialogue.emit(relevant_text, "", avatar_name)
	

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

extends Control

## A 3D rotating gold letter that can be used in 2D scenes
## Uses a SubViewport to render 3D content for use in 2D games

@export var letter: String = "A"
@export var letter_item: PlayerInventory.Item

# TODO: Remove this. Doesn't do anything now that we switched to 2D
@export var rotation_speed: float = 90.0  # degrees per second
@export var font_size: int = 40

# TODO: Remove this. Should not be configurable
@export var float_intensity: float = 10.0

# TODO: Remove this. Should not be configurable 
@export var float_duration: float = 1.0

# TODO: Remove this
@export var letter_depth: float = 1.0 : set = set_letter_depth

@onready var letter_label: Label = find_child('Letter2D')

@onready var area_2d: Area2D = $Area2D
@onready var font_family: Font = preload("res://fonts/Sniglet-Regular.ttf")

var is_mesh_text_set: bool = false

# Audio player - made optional to prevent errors if node doesn't exist
var audio_player: AudioStreamPlayer

var original_rotation_speed: float
var is_collected: bool = false
var tween: Tween
var float_tween: Tween
var original_position: Vector2

func _ready():
	var level = GameState.current_level
	if GameState.collected_letter_items_by_level.has(level):
		if letter_item in GameState.collected_letter_items_by_level[level]:
			queue_free()
			return
	
	if letter_item == null:
		push_warning("[SecretLetter] letter_item is not set for letter '%s'. This letter won't persist across respawns." % letter)
	
	# Safely get the audio player if it exists
	audio_player = get_node_or_null("AudioStreamPlayer")
	
	area_2d.body_entered.connect(_on_body_entered)
	
	# Ensure the letter is set properly when the scene loads
	letter_label.text = letter.to_upper()
	
	# Apply font size from export property
	letter_label.add_theme_font_size_override("font_size", font_size)
	
	# Set pivot to center of the label for proper rotation
	# letter_label.pivot_offset = letter_label.size / 2.0
	
	# Start floating animation
	original_position = letter_label.position
	_start_floating_animation()

func _start_floating_animation():
	if float_tween:
		return
		
	float_tween = create_tween()
	float_tween.set_loops()
	
	const real_float_intensity = 5.0
	var half_duration = float_duration / 2.0
	var base_y = original_position.y
	
	float_tween.tween_property(letter_label, "position:y", base_y - real_float_intensity, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(letter_label, "position:y", base_y + real_float_intensity, float_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(letter_label, "position:y", base_y, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func set_letter(new_letter: String):
	letter = new_letter.to_upper()  # Convert to uppercase for consistency
	is_mesh_text_set = true
	
	letter_label.text = letter

func set_letter_depth(new_depth: float):
	letter_depth = new_depth

func _update_letter_text():
	pass

## Called when Chonki collides with the SecretLetter
func _on_body_entered(body: Node2D):
	# Check if it's Chonki (CharacterBody2D)
	if body is CharacterBody2D and not is_collected:
		is_collected = true
		_start_collection_sequence()

## Start the collection animation sequence
func _start_collection_sequence():
	var level = GameState.current_level
	if letter_item != null and GameState.collected_letter_items_by_level.has(level):
		if letter_item not in GameState.collected_letter_items_by_level[level]:
			GameState.collected_letter_items_by_level[level].append(letter_item)
	
	GameState.add_collected_letter(letter)
	GlobalSignals.secret_letter_collected.emit(letter_item)
	
	# Play the secret letter collection sound
	if audio_player:
		audio_player.play()
	
	if float_tween:
		float_tween.kill()
	
	var color_tween = create_tween()
	color_tween.tween_property(letter_label, "modulate", Color(1, 1, 0, 1), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(letter_label, "rotation", TAU, 0.5).set_trans(Tween.TRANS_LINEAR)
	rotation_tween.tween_callback(func(): letter_label.rotation = 0)
	
	await get_tree().create_timer(2.0).timeout
	_start_shrinking()

## Shrink the letter to 1/10th size over 0.5 seconds
func _start_shrinking():
	if float_tween:
		float_tween.kill()
	if tween:
		tween.kill()
	
	tween = create_tween()
	var target_scale = scale * 0.1
	
	# Shrink over 0.5 seconds
	tween.tween_property(self, "scale", target_scale, 0.5)
	
	# When shrinking is complete, queue free
	tween.tween_callback(queue_free)

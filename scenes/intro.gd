extends Node2D

@onready var letters_discovered_layer: CanvasLayer = $TitleLayers/LettersDiscoveredLayer
@onready var letters_discovered_control: Control = $TitleLayers/LettersDiscoveredLayer/Control
@onready var letters_count_label: Label = $TitleLayers/LettersDiscoveredLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label

var player_moved_initially: bool = false
var total_secret_letters: int = 0
var collected_secret_letters: int = 0

func _ready():
	GlobalSignals.game_zoom_level.emit(0.2)
	
	# Connect to secret letter collection signal
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	# Count total secret letters in the scene
	_count_total_secret_letters()
	print("Found ", total_secret_letters, " secret letters in the scene")
	
	# Initialize the display
	_update_letters_count_display()
	
	# Add fade-in effect when scene loads
	_add_fade_in_effect()
	
	# Debugging - @nocommit
	GameState.add_collected_letter("A")
	GameState.add_collected_letter("D")
	GameState.add_collected_letter("O")
	GameState.add_collected_letter("P")
	GameState.add_collected_letter("T")

## Count all SecretLetter instances in the scene
func _count_total_secret_letters():
	total_secret_letters = 0
	
	# First try to find them in the StoryLetters group
	var story_letters = get_node_or_null("Items/StoryLetters")
	if story_letters:
		for child in story_letters.get_children():
			if child.name.begins_with("SecretLetter"):
				total_secret_letters += 1
	
	# Fallback: search by group
	if total_secret_letters == 0:
		var secret_letters = get_tree().get_nodes_in_group("secret_letters")
		total_secret_letters = secret_letters.size()
	
	# Final fallback: recursive search
	if total_secret_letters == 0:
		total_secret_letters = _count_secret_letters_recursive(self)

## Recursively count SecretLetter nodes
func _count_secret_letters_recursive(node: Node) -> int:
	var count = 0
	
	# Check if this node has the SecretLetter script
	if node.get_script() and node.get_script().get_path().ends_with("SecretLetter.gd"):
		count += 1
	
	# Check all children recursively
	for child in node.get_children():
		count += _count_secret_letters_recursive(child)
	
	return count

## Update the letters count display
func _update_letters_count_display():
	if letters_count_label:
		letters_count_label.text = "%d/%d" % [collected_secret_letters, total_secret_letters]
	
func _add_fade_in_effect():
	# Create a black overlay for fade-in effect
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 1.0  # Start fully opaque
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.z_index = 1000  # Ensure it's on top
	
	# Add to a CanvasLayer to ensure proper layering
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	canvas_layer.add_child(fade_overlay)
	
	# Fade in over 0.5 seconds
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	
	# Clean up the overlay
	canvas_layer.queue_free()
	
func _process(_delta) -> void:
	if !player_moved_initially && (Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right")):
		player_moved_initially = true
		# Zoom out a bit to see all the puppies and mother corgi
		GlobalSignals.game_zoom_level.emit(0.075)		


func _on_little_free_library_body_entered(_body):
	pass # Replace with function body.

## Handle secret letter collection and animate the LettersDiscoveredLayer
func _on_secret_letter_collected(_letter: String):
	if not letters_discovered_control:
		return
	
	# Increment collected count
	collected_secret_letters += 1
	print("Secret letter collected: ", _letter, " (", collected_secret_letters, "/", total_secret_letters, ")")
	
	# Update the display
	_update_letters_count_display()
	
	# Create fade in/out animation
	var tween = create_tween()
	
	# Fade in over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 1.0, 0.5)
	
	# Stay visible for 3.5 seconds
	tween.tween_interval(3.5)
	
	# Fade out over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 0.0, 0.5)

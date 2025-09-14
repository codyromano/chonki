extends Node2D

@onready var letters_discovered_layer: CanvasLayer = $TitleLayers/LettersDiscoveredLayer
@onready var letters_discovered_control: Control = $TitleLayers/LettersDiscoveredLayer/Control

var player_moved_initially: bool = false

func _ready():
	GlobalSignals.game_zoom_level.emit(0.2)
	
	# Connect to secret letter collection signal
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	# Add fade-in effect when scene loads
	_add_fade_in_effect()
	
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
	
	# Create fade in/out animation
	var tween = create_tween()
	
	# Fade in over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 1.0, 0.5)
	
	# Stay visible for 3.5 seconds
	tween.tween_interval(3.5)
	
	# Fade out over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 0.0, 0.5)

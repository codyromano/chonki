extends Node2D

@onready var letters_discovered_layer: CanvasLayer = $TitleLayers/LettersDiscoveredLayer
@onready var letters_discovered_control: Control = $TitleLayers/LettersDiscoveredLayer/Control
@onready var letters_count_label: Label = $TitleLayers/LettersDiscoveredLayer/Control/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Label

var player_moved_initially: bool = false

func _ready():
	GlobalSignals.game_zoom_level.emit(0.2)
	
	GameState.restore_letters_from_persistent_state(1)
	
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
	
	# GlobalSignals.queue_main_dialogue.emit("Adoption day!")
	GlobalSignals.queue_main_dialogue.emit(
		"It's adoption day! I need to find a way out of this barn to meet my owner.",
		"",
		"gus"
	)
	
func _process(_delta) -> void:
	if !player_moved_initially && (Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right")):
		player_moved_initially = true
		# Zoom out a bit to see all the puppies and mother corgi
		GlobalSignals.game_zoom_level.emit(0.075)		


func _on_little_free_library_body_entered(_body):
	pass # Replace with function body.

func _on_secret_letter_collected(_letter_item: PlayerInventory.Item):
	if not letters_discovered_control:
		return
	
	if letters_count_label:
		var collected = PlayerInventory.get_collected_secret_letter_count()
		letters_count_label.text = "%d/5" % collected
	
	var tween = create_tween()
	
	# Fade in over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 1.0, 0.5)
	
	# Stay visible for 3.5 seconds
	tween.tween_interval(3.5)
	
	# Fade out over 0.5 seconds
	tween.tween_property(letters_discovered_control, "modulate:a", 0.0, 0.5)

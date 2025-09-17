extends Node

@export var enter_library_fade_duration: float = 1.0

var fade_overlay: ColorRect
var tween: Tween
var canvas_layer: CanvasLayer
var is_transitioning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to the enter_little_free_library signal
	GlobalSignals.enter_little_free_library.connect(_on_enter_little_free_library)
	
	# Create fade overlay
	create_fade_overlay()
	
	# Clear any existing fade when scene becomes active again
	call_deferred("clear_fade")

func clear_fade():
	# Reset the fade overlay to transparent when returning to this scene
	if fade_overlay:
		fade_overlay.color.a = 0.0
		print("Fade overlay cleared - alpha set to 0")
	
	# Reset transition flag when returning to this scene
	is_transitioning = false
	
	# Unfreeze Chonki when scene loads/becomes active
	GlobalSignals.set_chonki_frozen.emit(false)
	
	# Re-register the player for audio when scene is restored
	for child in get_tree().current_scene.get_children():
		if child.name.begins_with("Chonki") or child.has_method("_on_player_jump"):
			print("Re-registering player for audio: ", child.name)
			GlobalSignals.player_registered.emit(child)
			break

func create_fade_overlay():
	# Don't create if overlay already exists
	if fade_overlay:
		print("Fade overlay already exists, skipping creation")
		return
		
	print("Creating fade overlay...")
	
	# Create a CanvasLayer to ensure the overlay is on top of everything
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer value to be on top
	get_tree().current_scene.call_deferred("add_child", canvas_layer)
	
	# Create the ColorRect for fading
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.color.a = 0.0  # Start transparent
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add to canvas layer first, then set size
	canvas_layer.call_deferred("add_child", fade_overlay)
	call_deferred("setup_overlay_size")

func setup_overlay_size():
	if fade_overlay:
		# Set to full screen size
		var viewport_size = get_viewport().get_visible_rect().size
		fade_overlay.size = viewport_size
		fade_overlay.position = Vector2.ZERO
		print("Overlay setup complete - Size: ", fade_overlay.size)

func _on_enter_little_free_library():
	print("Enter little free library signal received")
	
	if is_transitioning:
		print("Already transitioning, ignoring signal")
		return
	
	# Set flag immediately to prevent multiple signals
	is_transitioning = true
	
	# Freeze Chonki before starting the transition
	GlobalSignals.set_chonki_frozen.emit(true)
	
	print("Transition flag set - starting fade")
	fade_to_black()

func fade_to_black():
	if not fade_overlay:
		print("Error: fade_overlay is null!")
		return
		
	print("Starting fade to black")
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 0.5)  # Fade to black over 0.5 seconds
	tween.tween_callback(_on_fade_complete)

func _on_fade_complete():
	print("Fade to black complete - loading little free library scene")
	print("time to save scene")
	
	var library_scene = load("res://scenes/little_free_library.tscn")
	print("About to call SceneStack.push_scene")
	SceneStack.push_scene(library_scene)
	print("SceneStack.push_scene completed")
	
	# Reset the transition flag
	is_transitioning = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

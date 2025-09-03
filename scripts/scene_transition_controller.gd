extends Node

@export var enter_library_fade_duration: float = 1.0

var fade_overlay: ColorRect
var tween: Tween
var canvas_layer: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to the enter_little_free_library signal
	GlobalSignals.enter_little_free_library.connect(_on_enter_little_free_library)
	
	# Create fade overlay
	create_fade_overlay()

func create_fade_overlay():
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
	fade_to_black()

func fade_to_black():
	if not fade_overlay:
		print("Error: fade_overlay is null!")
		return
		
	print("Starting fade to black")
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 3.0)  # Fade to black over 3 seconds
	tween.tween_callback(_on_fade_complete)

func _on_fade_complete():
	print("Fade to black complete - loading little free library scene")
	# Load the little free library scene
	get_tree().change_scene_to_file("res://scenes/little_free_library.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

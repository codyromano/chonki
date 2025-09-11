extends Node

@export var fade_in_duration: float = 1.0
@export var display_duration: float = 2.0
@export var fade_out_duration: float = 1.0

var images: Array[TextureRect]

func _ready() -> void:
	print("SlideshowController _ready() called")
	
	# Get all TextureRect children
	for child in get_children():
		print("Found child: ", child.name, " (type: ", child.get_class(), ")")
		if child is TextureRect:
			images.append(child)
			print("Added TextureRect: ", child.name)
	
	print("Total TextureRects found: ", images.size())
	
	if images.is_empty():
		print("SlideshowController: No TextureRect children found. Aborting.")
		return

	# Sort children by name numerically to ensure correct order
	images.sort_custom(func(a, b): 
		var a_num = a.name.to_int() if a.name.is_valid_int() else 0
		var b_num = b.name.to_int() if b.name.is_valid_int() else 0
		return a_num < b_num
	)

	print("Images after sorting: ", images)

	# Hide all images initially
	for image in images:
		image.modulate.a = 0.0
		image.visible = false
		print("Set ", image.name, " alpha to 0 and visible to false")
	
	# Start the slideshow
	print("Starting slideshow...")
	_start_slideshow()

# Use an async function for clean, sequential animations
func _start_slideshow() -> void:
	print("_start_slideshow() called with ", images.size(), " images")
	
	for i in range(images.size()):
		var image = images[i]
		print("Starting animation for image ", i + 1, ": ", image.name)
		
		# Make the image visible and ready for fade in
		image.visible = true
		image.modulate.a = 0.0
		
		# --- Fade In ---
		print("Fading in ", image.name)
		var fade_in_tween = create_tween()
		fade_in_tween.tween_property(image, "modulate:a", 1.0, fade_in_duration)
		await fade_in_tween.finished
		print("Fade in complete for ", image.name)
		
		# --- Wait for Display Duration ---
		print("Displaying ", image.name, " for ", display_duration, " seconds")
		await get_tree().create_timer(display_duration).timeout
		print("Display time complete for ", image.name)
		
		# --- Fade Out ---
		print("Fading out ", image.name)
		var fade_out_tween = create_tween()
		fade_out_tween.tween_property(image, "modulate:a", 0.0, fade_out_duration)
		await fade_out_tween.finished
		print("Fade out complete for ", image.name)
		
		# Hide the image completely after fade out
		image.visible = false
		print("Set ", image.name, " visibility to false")
	
	print("Slideshow finished.")

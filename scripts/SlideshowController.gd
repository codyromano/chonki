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
		print("Displaying image ", i + 1, ": ", image.name)
		
		# Show the image immediately
		image.visible = true
		image.modulate.a = 1.0
		
		# --- Wait for Display Duration ---
		var current_display_duration = 3.0 if (i == images.size() - 1) else display_duration
		print("Displaying ", image.name, " for ", current_display_duration, " seconds")
		await get_tree().create_timer(current_display_duration).timeout
		print("Display time complete for ", image.name)
		
		# If this is the final image, fade out the image first
		if i == images.size() - 1:
			# Add 1-second fade out for the final image
			print("Final image - fading out image over 1 second...")
			var image_fade_tween = create_tween()
			image_fade_tween.tween_property(image, "modulate:a", 0.0, 1.0)
			await image_fade_tween.finished
			print("Final image fade out complete")
		
		# Hide the image immediately (except final image which already faded out)
		if i < images.size() - 1:
			image.visible = false
			image.modulate.a = 0.0
			print("Hidden ", image.name)
	
	print("Slideshow finished. Starting fade to black and music fade out...")
	
	# Create a black overlay for fade effect
	var black_overlay = ColorRect.new()
	black_overlay.color = Color.BLACK
	black_overlay.modulate.a = 0.0
	black_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().current_scene.add_child(black_overlay)
	
	# Start both music fade out and black overlay fade simultaneously
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)  # Allow multiple tweens to run simultaneously
	
	# Fade to black over 2 seconds
	fade_tween.tween_property(black_overlay, "modulate:a", 1.0, 2.0)
	
	# Fade out music over 3 seconds (overlapping with black fade)
	print("Music fading out over 3 seconds while scene fades to black...")
	var audio_players = _find_all_audio_players(get_tree().current_scene)
	for audio_player in audio_players:
		if audio_player.playing:
			fade_tween.tween_property(audio_player, "volume_db", -80.0, 3.0)
	
	await fade_tween.finished
	print("Fade complete. Navigating to intro.tscn...")
	
	# Navigate to intro.tscn
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

# Helper function to find all audio players in the scene
func _find_all_audio_players(node: Node) -> Array:
	var audio_players = []
	
	# Check if current node is an audio player
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		audio_players.append(node)
	
	# Recursively check all children
	for child in node.get_children():
		audio_players.append_array(_find_all_audio_players(child))
	
	return audio_players

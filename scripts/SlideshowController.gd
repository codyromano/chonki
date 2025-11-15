extends Node

@export var fade_in_duration: float = 1.0
@export var display_duration: float = 2.0
@export var fade_out_duration: float = 1.0
@export var crop_bottom_pixels: int = 25  # Pixels to crop from bottom of each image
@export var title_fade_duration: float = 0.25
@export var title_display_duration: float = 5.0

var images: Array[TextureRect]
var slides: Array[Control]  # Holds both images and title cards in order

func _ready() -> void:
	print("SlideshowController _ready() called")
	
	# Get all TextureRect and Control children (title cards)
	for child in get_children():
		print("Found child: ", child.name, " (type: ", child.get_class(), ")")
		if child is TextureRect:
			images.append(child)
			slides.append(child)
			print("Added TextureRect: ", child.name)
		elif child is Control and child.name.begins_with("Title"):
			slides.append(child)
			print("Added TitleCard: ", child.name)
	
	print("Total slides found: ", slides.size(), " (TextureRects: ", images.size(), ")")
	
	if slides.is_empty():
		print("SlideshowController: No slides found. Aborting.")
		return

	# Apply cropping to all images before starting slideshow
	if crop_bottom_pixels > 0:
		_apply_cropping_to_images()

	# Sort slides by name numerically to ensure correct order
	slides.sort_custom(func(a, b): 
		# Extract number from name (e.g., "Title1" -> 1, "Image2" -> 2)
		var a_name = str(a.name)
		var b_name = str(b.name)
		var a_num = 0
		var b_num = 0
		
		# Extract numbers from names like "Title1", "Image2", etc.
		for i in range(a_name.length()):
			if a_name[i].is_valid_int():
				a_num = a_name.substr(i).to_int()
				break
		for i in range(b_name.length()):
			if b_name[i].is_valid_int():
				b_num = b_name.substr(i).to_int()
				break
		
		return a_num < b_num
	)

	print("Slides after sorting: ", slides.map(func(s): return s.name))

	# Hide all slides initially
	for slide in slides:
		slide.modulate.a = 0.0
		slide.visible = false
		print("Set ", slide.name, " alpha to 0 and visible to false")
	
	# Start the slideshow
	print("Starting slideshow...")
	_start_slideshow()

# Use an async function for clean, sequential animations
func _start_slideshow() -> void:
	print("_start_slideshow() called with ", slides.size(), " slides")
	
	for i in range(slides.size()):
		var slide = slides[i]
		var is_title_card = slide.name.begins_with("Title")
		print("Displaying slide ", i + 1, ": ", slide.name, " (is_title: ", is_title_card, ")")
		
		# Determine fade and display durations based on slide type
		var fade_in: float
		var display_time: float
		var fade_out: float
		
		if is_title_card:
			# Title cards: 0.25s fade in/out, 5s display
			fade_in = title_fade_duration
			display_time = title_display_duration
			fade_out = title_fade_duration
		else:
			# Images: use export variables
			fade_in = fade_in_duration
			fade_out = fade_out_duration
			
			# Adjust display duration for special images
			if i == 0:
				display_time = display_duration * 2.0
			elif i == slides.size() - 1:
				display_time = 3.0
			else:
				display_time = display_duration
		
		# Fade in
		slide.visible = true
		if fade_in > 0:
			print("Fading in ", slide.name, " over ", fade_in, " seconds")
			var fade_in_tween = create_tween()
			fade_in_tween.tween_property(slide, "modulate:a", 1.0, fade_in)
			await fade_in_tween.finished
		else:
			slide.modulate.a = 1.0
		
		# Display
		print("Displaying ", slide.name, " for ", display_time, " seconds")
		await get_tree().create_timer(display_time).timeout
		print("Display time complete for ", slide.name)
		
		# Fade out
		if fade_out > 0:
			print("Fading out ", slide.name, " over ", fade_out, " seconds")
			var fade_out_tween = create_tween()
			fade_out_tween.tween_property(slide, "modulate:a", 0.0, fade_out)
			await fade_out_tween.finished
		else:
			slide.modulate.a = 0.0
		
		# Hide the slide
		slide.visible = false
		print("Hidden ", slide.name)
	
	print("Slideshow finished. Starting final fade...")
	
	# Check if we're in the after_intro_animation_sequence scene
	var current_scene_name = get_tree().current_scene.name
	var is_after_intro_scene = current_scene_name == "after_intro_animation_sequence"
	var is_final_animation_scene = current_scene_name == "final_animation_sequence"
	
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
	print("Fade complete.")
	
	# Remove the black overlay
	black_overlay.queue_free()
	
	# Handle different scenes differently
	if is_after_intro_scene:
		# For after_intro_animation_sequence: transition to level1.tscn
		print("Transitioning to level1.tscn...")
		FadeTransition.fade_out_and_change_scene("res://scenes/level1.tscn")
	elif is_final_animation_scene:
		# For final_animation_sequence: transition to bonus level
		print("Game complete! Transitioning to bonus level...")
		FadeTransition.fade_out_and_change_scene("res://scenes/bonus.tscn")
	else:
		# For other opening animation sequences: transition to intro.tscn
		print("Transitioning to intro.tscn...")
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

# Apply cropping shader to all images in the slideshow
func _apply_cropping_to_images():
	print("SlideshowController: Applying %d pixel crop to %d images" % [crop_bottom_pixels, images.size()])
	
	# Custom shader code for cropping bottom pixels
	var crop_shader_code = """
shader_type canvas_item;

uniform float crop_bottom : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	// Calculate the adjusted UV coordinates
	// We need to scale the UV.y to exclude the bottom portion
	vec2 adjusted_uv = UV;
	adjusted_uv.y = UV.y * (1.0 - crop_bottom);
	
	// Sample the texture with the adjusted coordinates
	COLOR = texture(TEXTURE, adjusted_uv);
	
	// Make cropped area transparent
	if (UV.y > (1.0 - crop_bottom)) {
		COLOR.a = 0.0;
	}
}
"""
	
	for image in images:
		if not image.texture:
			print("SlideshowController: Skipping %s - no texture assigned" % image.name)
			continue
			
		# Get the texture dimensions to calculate crop ratio
		var texture_size = image.texture.get_size()
		var crop_ratio = float(crop_bottom_pixels) / texture_size.y
		
		# Create the shader material
		var shader = Shader.new()
		shader.code = crop_shader_code
		
		var shader_material = ShaderMaterial.new()
		shader_material.shader = shader
		shader_material.set_shader_parameter("crop_bottom", crop_ratio)
		
		# Apply the material to the TextureRect
		image.material = shader_material
		
		print("SlideshowController: Applied crop to %s (crop ratio: %.3f)" % [image.name, crop_ratio])

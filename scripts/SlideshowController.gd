extends Node

@export var fade_in_duration: float = 1.0
@export var display_duration: float = 2.0
@export var fade_out_duration: float = 1.0
@export var crop_bottom_pixels: int = 25  # Pixels to crop from bottom of each image
@export var title_fade_duration: float = 0.25
@export var title_display_duration: float = 5.0

var images: Array[TextureRect]
var slides: Array[Control]  # Holds both images and title cards in order
var fade_controller: FadeController
var is_skipping: bool = false
var slideshow_running: bool = false

func _ready() -> void:
	fade_controller = FadeController.new(get_tree().current_scene)
	
	for child in get_children():
		if child is TextureRect:
			images.append(child)
			slides.append(child)
		elif child is Control and child.name.begins_with("Title"):
			slides.append(child)
	
	if slides.is_empty():
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

	for slide in slides:
		slide.modulate.a = 1.0
		slide.visible = false
	
	slideshow_running = true
	_start_slideshow()

func _process(_delta: float) -> void:
	if slideshow_running and !is_skipping and Input.is_action_just_pressed("ui_accept"):
		is_skipping = true
		_skip_to_end()

func _skip_to_end() -> void:
	var audio_players = _find_all_audio_players(get_tree().current_scene)
	
	var fade_tween = get_tree().create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.set_parallel(true)
	
	for audio_player in audio_players:
		if audio_player.playing:
			fade_tween.tween_property(audio_player, "volume_db", -80.0, 1.0)
	
	await fade_controller.fade_to_black(1.0)
	
	for slide in slides:
		slide.visible = false
	
	_transition_to_next_scene()

func _start_slideshow() -> void:
	for i in range(slides.size()):
		if is_skipping:
			return
			
		var slide = slides[i]
		var is_title_card = slide.name.begins_with("Title")
		
		# Determine fade and display durations based on slide type
		var fade_in: float
		var display_time: float
		
		if is_title_card:
			# Title cards: 0.25s fade in/out, 5s display
			fade_in = title_fade_duration
			display_time = title_display_duration
		else:
			# Images: use export variables
			fade_in = fade_in_duration
			
			# Adjust display duration for special images
			var current_scene_name = get_tree().current_scene.name
			var is_after_intro_scene = current_scene_name == "after_intro_animation_sequence"
			
			if i == 0 and is_after_intro_scene:
				display_time = display_duration * 2.0
			elif i == slides.size() - 1:
				display_time = 3.0
			else:
				display_time = display_duration
		
		# Show slide
		slide.visible = true
		slide.modulate.a = 1.0
		
		# Fade in only for first slide
		if i == 0:
			if fade_in > 0:
				await fade_controller.fade_to_clear(fade_in)
			else:
				fade_controller.set_clear()
		else:
			fade_controller.set_clear()
		
		if is_skipping:
			return
		
		await get_tree().create_timer(display_time, false).timeout
		
		if is_skipping:
			return
			
		slide.visible = false
	
	if is_skipping:
		return
	
	var audio_players = _find_all_audio_players(get_tree().current_scene)
	await fade_controller.fade_to_black_with_audio(2.0, 3.0, audio_players)
	
	_transition_to_next_scene()

func _transition_to_next_scene() -> void:
	slideshow_running = false
	
	var current_scene_name = get_tree().current_scene.name
	var is_after_intro_scene = current_scene_name == "after_intro_animation_sequence"
	var is_final_animation_scene = current_scene_name == "final_animation_sequence"
	
	if is_after_intro_scene:
		GameState.letters_collected_by_scene[1] = []
		GameState.letters_collected_by_scene[2] = []
		get_tree().change_scene_to_file("res://scenes/level1.tscn")
	elif is_final_animation_scene:
		FadeTransition.fade_out_and_change_scene("res://scenes/bonus.tscn", 0.0, 1.0)
	else:
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

func _apply_cropping_to_images():
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
		
		image.material = shader_material

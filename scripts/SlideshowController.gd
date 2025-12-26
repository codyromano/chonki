extends Node

var slides: Array[Control]
var fade_controller: FadeController
var is_skipping: bool = false
var slideshow_running: bool = false
var active_tweens: Array[Tween] = []

func _ready() -> void:
	fade_controller = FadeController.new(get_tree().current_scene)
	
	for child in get_children():
		if child is Control and "display_duration" in child and "overlay_text" in child:
			slides.append(child)
	
	if slides.is_empty():
		return

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
	for tween in active_tweens:
		if tween and tween.is_valid():
			tween.kill()
	active_tweens.clear()
	
	var audio_players = _find_all_audio_players(get_tree().current_scene)
	for audio_player in audio_players:
		if audio_player.playing:
			audio_player.stop()
	
	for slide in slides:
		slide.visible = false
	
	_transition_to_next_scene()

func _start_slideshow() -> void:
	var audio_players = _find_all_audio_players(get_tree().current_scene)
	
	for i in range(slides.size()):
		if is_skipping:
			return
			
		var slide = slides[i]
		
		var display_time: float = slide.display_duration if "display_duration" in slide else 3.0
		
		slide.visible = true
		slide.modulate.a = 1.0
		
		if i == 0:
			for audio_player in audio_players:
				if not audio_player.playing:
					audio_player.play()
			
			await fade_controller.fade_to_clear(0.5)
		else:
			# Cross-fade with previous slide
			var previous_slide = slides[i - 1]
			
			# Create parallel tweens for cross-fade
			var fade_out_tween = create_tween()
			fade_out_tween.set_trans(Tween.TRANS_LINEAR)
			fade_out_tween.tween_property(previous_slide, "modulate:a", 0.0, 0.5)
			active_tweens.append(fade_out_tween)
			
			var fade_in_tween = create_tween()
			fade_in_tween.set_trans(Tween.TRANS_LINEAR)
			fade_in_tween.tween_property(slide, "modulate:a", 1.0, 0.5).from(0.0)
			active_tweens.append(fade_in_tween)
			
			await fade_in_tween.finished
			
			# Hide previous slide after cross-fade
			previous_slide.visible = false
			
			# Clean up finished tweens
			active_tweens.erase(fade_out_tween)
			active_tweens.erase(fade_in_tween)
		
		if is_skipping:
			return
		
		await get_tree().create_timer(display_time, false).timeout
		
		if is_skipping:
			return
	
	# Last slide visible, fade to black
	if is_skipping:
		return
	
	await fade_controller.fade_to_black_with_audio(2.0, 3.0, audio_players)
	
	# Hide all slides after fade to black
	for slide in slides:
		slide.visible = false
	
	_transition_to_next_scene()

func _transition_to_next_scene() -> void:
	slideshow_running = false
	
	var current_scene_name = get_tree().current_scene.name
	var is_after_intro_scene = current_scene_name == "after_intro_animation_sequence"
	var is_final_animation_scene = current_scene_name == "final_animation_sequence"
	
	if is_after_intro_scene:
		GameState.letters_collected_by_scene[1] = []
		GameState.letters_collected_by_scene[2] = []
		GlobalSignals.on_unload_scene.emit(get_tree().current_scene.scene_file_path if get_tree().current_scene else "")
		get_tree().change_scene_to_file("res://scenes/level1.tscn")
	elif is_final_animation_scene:
		FadeTransition.fade_out_and_change_scene("res://scenes/bonus.tscn", 0.0, 1.0)
	else:
		GlobalSignals.on_unload_scene.emit(get_tree().current_scene.scene_file_path if get_tree().current_scene else "")
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

extends CanvasLayer

var fade_rect: ColorRect
var is_fading: bool = false
var _previous_scene_path: String = ""
var message_label: Label

func _ready():
	# Create a fullscreen ColorRect for fade effect
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1000
	fade_rect.visible = false
	add_child(fade_rect)
	
	var center_container = CenterContainer.new()
	center_container.anchor_right = 1.0
	center_container.anchor_bottom = 1.0
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_container.z_index = 1001
	center_container.visible = false
	add_child(center_container)
	
	message_label = Label.new()
	message_label.custom_minimum_size = Vector2(1400, 0)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	var font = load("res://fonts/Sniglet-Regular.ttf")
	var label_settings = LabelSettings.new()
	label_settings.font = font
	label_settings.font_size = 80
	label_settings.outline_size = 6
	label_settings.outline_color = Color(0, 0, 0, 1)
	message_label.label_settings = label_settings
	message_label.modulate = Color(1, 1, 1, 0)
	center_container.add_child(message_label)

func fade_out(duration: float = 3.0):
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	await tween.finished

func fade_in(duration: float = 3.0):
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.visible = true
	fade_rect.size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade_rect, "color:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	fade_rect.visible = false

func show_message_and_reload(message: String, text_fade_duration: float = 0.25, text_display_duration: float = 4.0, scene_path: String = "") -> void:
	if is_fading:
		return
	is_fading = true
	
	var target_scene = scene_path if scene_path != "" else get_tree().current_scene.scene_file_path
	
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 1)
	
	message_label.text = message
	message_label.get_parent().visible = true
	var fade_in_tween = create_tween()
	fade_in_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_in_tween.tween_property(message_label, "modulate:a", 1.0, text_fade_duration)
	await fade_in_tween.finished
	
	await get_tree().create_timer(text_display_duration, false).timeout
	
	var fade_out_tween = create_tween()
	fade_out_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_out_tween.tween_property(message_label, "modulate:a", 0.0, text_fade_duration)
	await fade_out_tween.finished
	
	message_label.get_parent().visible = false
	
	get_tree().change_scene_to_file(target_scene)
	await get_tree().process_frame
	
	await fade_in(1.0)
	is_fading = false

func fade_out_and_change_scene(scene_path: String, delay: float = 5.0, fade_duration: float = 3.0) -> void:
	if is_fading:
		return
	is_fading = true
	# Store the current scene path before changing
	_previous_scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	await get_tree().create_timer(delay, false).timeout
	await fade_out(fade_duration)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_in(fade_duration)
	is_fading = false

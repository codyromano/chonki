extends CanvasLayer

var fade_rect: ColorRect
var is_fading: bool = false

func _ready():
	# Create a fullscreen ColorRect for fade effect
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1000
	fade_rect.visible = false
	add_child(fade_rect)

func fade_out(duration: float = 3.0):
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	await tween.finished

func fade_in(duration: float = 3.0):
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.visible = true
	fade_rect.size = get_viewport().get_visible_rect().size
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	await tween.finished
	fade_rect.visible = false

func fade_out_and_change_scene(scene_path: String, delay: float = 5.0, fade_duration: float = 3.0) -> void:
	if is_fading:
		return
	is_fading = true
	await get_tree().create_timer(delay).timeout
	await fade_out(fade_duration)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_in(fade_duration)
	is_fading = false

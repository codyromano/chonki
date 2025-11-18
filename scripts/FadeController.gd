extends RefCounted

class_name FadeController

var overlay: ColorRect
var parent: Node
var tween: Tween
var canvas_layer: CanvasLayer

func _init(parent_node: Node) -> void:
	parent = parent_node
	_create_overlay.call_deferred()

func _create_overlay() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	parent.add_child(canvas_layer)
	
	overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 1.0
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 0.0
	overlay.offset_bottom = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(overlay)

func fade_to_black(duration: float) -> void:
	await _ensure_overlay_ready()
	if tween:
		tween.kill()
	
	tween = parent.create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, duration)
	await tween.finished

func fade_to_clear(duration: float) -> void:
	await _ensure_overlay_ready()
	if tween:
		tween.kill()
	
	tween = parent.create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	await tween.finished

func set_black() -> void:
	await _ensure_overlay_ready()
	overlay.modulate.a = 1.0

func set_clear() -> void:
	await _ensure_overlay_ready()
	overlay.modulate.a = 0.0

func _ensure_overlay_ready() -> void:
	while not overlay:
		await parent.get_tree().process_frame

func fade_to_black_with_audio(visual_duration: float, audio_duration: float, audio_players: Array) -> void:
	await _ensure_overlay_ready()
	if tween:
		tween.kill()
	
	tween = parent.create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(overlay, "modulate:a", 1.0, visual_duration)
	
	for audio_player in audio_players:
		if audio_player.playing:
			tween.tween_property(audio_player, "volume_db", -80.0, audio_duration)
	
	await tween.finished

func cleanup() -> void:
	if tween:
		tween.kill()
	if canvas_layer:
		canvas_layer.queue_free()

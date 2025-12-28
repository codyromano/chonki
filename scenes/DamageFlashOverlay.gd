extends CanvasLayer

var flash_overlay: ColorRect

func _ready():
	layer = 100
	
	flash_overlay = ColorRect.new()
	flash_overlay.color = Color(1.0, 0.4, 0.5, 0.0)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.z_index = 1000
	add_child(flash_overlay)
	
	GlobalSignals.connect("player_hit", _on_player_hit)

func _on_player_hit(_source: String):
	if flash_overlay.color.a > 0.0:
		return
	
	var tween = create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.5, 0.2)
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.2)

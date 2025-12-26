extends Control

@export var texture: Texture2D
@export_multiline var overlay_text: String = ""
@export_range(3.0, 999.0) var display_duration: float = 3.0

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var center_container: CenterContainer = $VBoxContainer/CenterContainer
@onready var label: Label = $VBoxContainer/CenterContainer/Label

func _ready() -> void:
	_adjust_texture_size()
	
	if texture_rect and texture:
		texture_rect.texture = texture
	
	if label:
		if overlay_text.is_empty():
			center_container.visible = false
		else:
			label.text = overlay_text

func _adjust_texture_size() -> void:
	if not texture_rect:
		return
	
	var viewport_height = get_viewport_rect().size.y
	var max_height = viewport_height * 0.75
	
	var desired_size = 1000.0
	var final_size = min(desired_size, max_height)
	
	texture_rect.custom_minimum_size = Vector2(final_size, final_size)

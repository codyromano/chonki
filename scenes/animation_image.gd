extends Control

@export var texture: Texture2D
@export_multiline var overlay_text: String = ""
@export_range(3.0, 999.0) var display_duration: float = 3.0
@export var is_chapter_title: bool = false
@export var chapter_number: int = 1

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var center_container: CenterContainer = $VBoxContainer/CenterContainer
@onready var label: Label = $VBoxContainer/CenterContainer/Label

func _ready() -> void:
	if is_chapter_title:
		_setup_chapter_title()
	else:
		_adjust_texture_size()
		
		if texture_rect and texture:
			texture_rect.texture = texture
	
	if label:
		if is_chapter_title:
			label.text = "Chapter " + str(chapter_number)
			if label.label_settings:
				var chapter_settings = label.label_settings.duplicate()
				chapter_settings.font_size = 120
				chapter_settings.outline_size = 10
				label.label_settings = chapter_settings
		elif overlay_text.is_empty():
			center_container.visible = false
		else:
			label.text = overlay_text

func _setup_chapter_title() -> void:
	if texture_rect:
		texture_rect.visible = false
	
	if center_container:
		center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _adjust_texture_size() -> void:
	if not texture_rect:
		return
	
	var viewport_height = get_viewport_rect().size.y
	var max_height = viewport_height * 0.75
	
	var desired_size = 1000.0
	var final_size = min(desired_size, max_height)
	
	texture_rect.custom_minimum_size = Vector2(final_size, final_size)

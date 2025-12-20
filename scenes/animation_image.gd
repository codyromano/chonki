extends Control

@export var texture: Texture2D
@export_multiline var overlay_text: String = ""
@export_range(3.0, 999.0) var display_duration: float = 3.0

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var center_container: CenterContainer = $VBoxContainer/CenterContainer
@onready var label: Label = $VBoxContainer/CenterContainer/Label

func _ready() -> void:
	if texture_rect and texture:
		texture_rect.texture = texture
	
	if label:
		if overlay_text.is_empty():
			center_container.visible = false
		else:
			label.text = overlay_text

extends Control

@export_multiline var title_text: String = "Title Text"

@onready var label: Label = $CenterContainer/Label

func _ready() -> void:
	if label:
		label.text = title_text

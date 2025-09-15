extends StaticBody2D

@export var has_rope: bool = true
@onready var rope: Polygon2D = find_child('Rope')

func _ready() -> void:
	rope.visible = has_rope

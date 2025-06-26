extends Node2D

func _ready():
	if Engine.has_singleton("FadeTransition"):
		FadeTransition.fade_in(3.0)

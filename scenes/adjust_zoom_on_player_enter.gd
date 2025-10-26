extends Area2D

@export var zoom_on_enter: float = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "GrownUpChonki" or body.name == "ChonkiCharacter":
		GlobalSignals.animate_camera_zoom_level.emit(zoom_on_enter)
extends StaticBody2D

var collided := false

func _on_body_entered(body):
	if not collided and body.name == "ChonkiCharacter":
		collided = true
		GlobalSignals.animate_camera_zoom_level.emit(0.15)


func _on_input_event(_viewport, _event, _shape_idx):
	print("foobar")

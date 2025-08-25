extends Area2D

@export var instructions_id: String

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == 'ChonkiCharacter':
		print("Display instructional text: " + instructions_id)
		GlobalSignals.display_instructional_text.emit(
			instructions_id
		)
		queue_free.call_deferred()

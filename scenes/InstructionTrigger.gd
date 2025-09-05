extends Area2D

@export var dialogue: String

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == 'ChonkiCharacter':
		GlobalSignals.queue_main_dialogue.emit(dialogue)
		queue_free.call_deferred()

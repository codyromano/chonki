extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		GlobalSignals.collected_jetpack.emit()
		call_deferred("queue_free")

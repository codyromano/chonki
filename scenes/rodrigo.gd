extends Area2D

func _on_body_entered(body: Node2D) -> void:
	var parent_name = str(body.get_parent().name) if body.get_parent() else "null"
	print("Rodrigo body_entered triggered! Body: ", body.name, " Parent: ", parent_name)
	if body.name == "ChonkiCharacter":
		var gus: Gus = body.get_parent()
		print("Setting Gus carried_entity to Rodrigo")
		gus.carried_entity = self
		
		print("Disabling Rodrigo collision")
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)
		
		print("Emitting rodrigo_picked_up signal")
		GlobalSignals.rodrigo_picked_up.emit()

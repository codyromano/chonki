extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# TODO: Collision utility: isGus
	if body.name == "ChonkiCharacter":
		var gus: Gus = body.get_parent()
		gus.carried_entity = self
		
		# TODO: Is this necessary?
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)

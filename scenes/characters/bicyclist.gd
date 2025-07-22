extends Area2D

func _on_body_entered(body):
	print("biker collided with " + body.name)
	
	if body.name == "ChonkiCharacter":
		# Bicycle hit is a KO
		GlobalSignals.player_hit.emit()
		GlobalSignals.player_hit.emit()
		GlobalSignals.player_hit.emit()
	if body.is_in_group("npc_obstacles"):
		GlobalSignals.biker_hit_branch.emit()

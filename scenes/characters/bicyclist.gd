extends Area2D

func _on_body_entered(body):
	if body.name == "ChonkiCharacter":
		GlobalSignals.player_hit.emit()
		GlobalSignals.player_hit.emit()
		GlobalSignals.player_hit.emit()
	if body.is_in_group("npc_obstacles"):
		GlobalSignals.biker_hit_branch.emit()

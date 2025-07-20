extends Area2D

func _on_body_entered(body):
	if body.name == "ChonkiCharacter":
		GlobalSignals.player_hit.emit()
	if body.name == "Branch":
		GlobalSignals.biker_hit_branch.emit()

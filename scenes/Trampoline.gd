extends Area2D

@export var trampoline_id: String

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		var trampoline_jump_intensity = 2
		
		# Check for special trampoline behaviors
		if trampoline_id == "horse_buck":
			GlobalSignals.horse_buck.emit()
			await get_tree().create_timer(0.25).timeout
			GlobalSignals.player_jump.emit(trampoline_jump_intensity)
		else:
			GlobalSignals.player_jump.emit(trampoline_jump_intensity)

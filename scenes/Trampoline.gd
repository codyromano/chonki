extends Area2D

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		# Trampoline jump intensity is twice that of a normal jump
		var trampoline_jump_intensity = 2.0
		GlobalSignals.player_jump.emit(trampoline_jump_intensity)

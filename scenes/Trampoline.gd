extends Area2D

@export var jump_intensity: float = 2.0
@export var trampoline_id: String

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		GlobalSignals.player_jump.emit(jump_intensity, "trampoline")

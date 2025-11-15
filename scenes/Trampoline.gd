extends Area2D

@export var jump_intensity: float = 2.0
@export var trampoline_id: String
@export var custom_texture: Texture2D

var backflip_triggered: bool = false

func _ready():
	if custom_texture:
		var sprite = $Sprite2D
		if sprite:
			sprite.texture = custom_texture

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		# Always apply jump force regardless of backflip state
		GlobalSignals.player_jump.emit(jump_intensity, "trampoline")
		w
		# Only trigger backflip if not already triggered
		if not backflip_triggered:
			backflip_triggered = true
			# Trigger backflip after 0.2 second delay
			await get_tree().create_timer(0.2).timeout
			GlobalSignals.backflip_triggered.emit()
			# Reset the flag after 1 second to allow future interactions
			await get_tree().create_timer(1.0).timeout
			backflip_triggered = false

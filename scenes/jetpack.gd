extends Area2D

@export var float_intensity: float = 30.0
@export var float_duration: float = 2.0
var float_tween: Tween
var base_y: float
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if sprite:
		base_y = sprite.position.y
		_start_floating()

func _start_floating():
	if float_tween:
		float_tween.kill()
	float_tween = create_tween()
	float_tween.set_loops()
	var half_duration = float_duration / 2.0
	float_tween.tween_property(sprite, "position:y", base_y - float_intensity, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(sprite, "position:y", base_y + float_intensity, float_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(sprite, "position:y", base_y, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		if float_tween:
			float_tween.kill()
		GlobalSignals.collected_jetpack.emit()
		call_deferred("queue_free")

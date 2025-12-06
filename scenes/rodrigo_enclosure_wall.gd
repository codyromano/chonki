extends Sprite2D

@export var collision_shape: CollisionShape2D

func _ready() -> void:
	GlobalSignals.rodrigo_picked_up.connect(_on_rodrigo_picked_up)

func _on_rodrigo_picked_up() -> void:
	print("Wall received rodrigo_picked_up signal, starting fade")
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	fade_tween.tween_callback(func():
		print("Wall fade complete, queue_free")
		if collision_shape:
			collision_shape.call_deferred("queue_free")
		call_deferred("queue_free")
	)

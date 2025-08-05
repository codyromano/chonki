extends Node

@export var sprite: Texture2D
@export var heart_texture: Texture2D

func spawn_floating_hearts() -> void:
	var frame_texture = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)
	var size: Vector2 = frame_texture.get_size() * sprite.scale
	
	for i in range(25):
		var heart = Sprite2D.new()
		heart.texture = heart_texture
		heart.scale = Vector2(0.5, 0.5)
		
		heart.global_position = sprite.global_position + Vector2(-(size.x / 2), size.y / 2)
		heart.modulate.a = 0.0
		add_child(heart)

		var direction = Vector2(randf() * 2.0 - 1.0, randf() * -1.5).normalized()
		# var distance = randf() * 200 + 100
		var distance = randf() * 2000 + 100
		var end_pos = heart.global_position + direction * distance

		var tween = create_tween()
		tween.tween_property(heart, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(heart, "global_position", end_pos, 6.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(heart, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(Callable(heart, "queue_free"))

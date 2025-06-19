extends Node2D

@export var frames: SpriteFrames
@export var collectible_name: String
@export var audio: AudioStream  # Allows .mp3, .ogg, etc.

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite")
@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)

	if frames:
		sprite.frames = frames
		sprite.speed_scale = 2
		sprite.play()
	else:
		push_warning("No SpriteFrames assigned to 'frames'.")

func _process(_delta):
	pass

func _on_static_body_2d_2_body_entered(body):
	if "on_item_collected" in body:
		body.on_item_collected(collectible_name)

		# Play sound (non-blocking)
		if audio:
			audio_player.stream = audio
			audio_player.play()

		# Animate in parallel over 2 seconds
		var duration = 2.0
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", sprite.scale * 1.5, duration)
		tween.tween_property(sprite, "rotation_degrees", sprite.rotation_degrees + 360, duration)
		tween.tween_property(sprite, "modulate:a", 0.0, duration)
		
		await audio_player.finished
		$ChillBark.play()
		
		await tween.finished
		queue_free()

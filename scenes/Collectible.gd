extends Node2D

@export var label_text: String
@export var frames: SpriteFrames
@export var collectible_name: String
@export var audio: AudioStream  # Allows .mp3, .ogg, etc.

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite")

# How far the collectible floats up and down (in pixels)
@export var float_intensity: float = 50.0
# How long one float cycle takes (in seconds)
@export var float_duration: float = 1
var float_tween: Tween
var base_y: float
@onready var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var label: Label = find_child('Label')

var is_collected: bool = false


# Override
func _on_item_collected(_item_name: String) -> void:
	pass

func _ready():
	add_child(audio_player)
	if label_text:
		label.text = label_text
	else:
		label.visible = false

	# Start floating animation
	if sprite:
		sprite.sprite_frames = frames
		base_y = sprite.position.y
		_start_floating()

	# Add to group for star counting
	if collectible_name == "star":
		add_to_group("CollectibleStar")

# Tween the sprite up and down forever
func _start_floating():
	if float_tween:
		float_tween.kill()
	float_tween = create_tween()
	float_tween.set_loops()
	# The total duration of a full up-and-down cycle should be float_duration
	var half_duration = float_duration / 2.0
	float_tween.tween_property(sprite, "position:y", base_y - float_intensity, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(sprite, "position:y", base_y + float_intensity, float_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(sprite, "position:y", base_y, half_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _process(_delta):
	pass  # _delta intentionally unused

func _on_static_body_2d_2_body_entered(body):
	if body.name != "ChonkiCharacter":
		return
	
	if is_collected:
		return
		
	_on_item_collected(collectible_name)

	if "on_item_collected" in body:
		# Interacting with a hint should not increase the count of books
		# collected in the HUD menu
		if !collectible_name.to_lower().contains('hint'):
			body.on_item_collected(collectible_name)
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("opened"):
				sprite.play("opened")

		# Play sound (non-blocking)
		if audio:
			audio_player.stream = audio
			audio_player.play()

		is_collected = true

		# Animate in parallel over 2 seconds
		var duration = 2.0
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", sprite.scale * 1.5, duration)
		tween.tween_property(sprite, "rotation_degrees", sprite.rotation_degrees + 360, duration)
		tween.tween_property(sprite, "modulate:a", 0.0, duration)
		
		tween.tween_property(label, "scale", sprite.scale * 1.5, duration)
		tween.tween_property(label, "modulate:a", 0.0, duration)

		await audio_player.finished
		$ChillBark.play()

		await tween.finished
		queue_free.call_deferred()

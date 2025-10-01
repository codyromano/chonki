extends Node2D

@export var frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)

var dialogue_tree: Resource

@onready var sprite: AnimatedSprite2D = find_child('QuestGiverSprite2D')
@onready var collision_shape: CollisionShape2D = find_child('QuestGiverCollisionShape')
@onready var instructions: Label = find_child('Instructions')

var tween_instructions: Tween

func _ready() -> void:
	sprite.sprite_frames = frames
	sprite.scale *= sprite_scale
	_prepare_collisions()
	
	dialogue_tree = _get_dialogue_tree()
	print('TODO: Use dialogue tree ', dialogue_tree)

func _get_dialogue_tree():
	push_warning("Quest giver should implement a dialogue tree")

# TODO: The collision_shape should overlaid onto the sprite
func _prepare_collisions() -> void:
		# Overlay the collision shape onto the sprite
		collision_shape.position = sprite.position
		collision_shape.scale = sprite.scale

		# Update the shape property to match the sprite's size
		var tex = sprite.get_sprite_frames().get_frame_texture(sprite.animation, 0)
		if tex and collision_shape.shape is RectangleShape2D:
			var rect_shape = collision_shape.shape
			rect_shape.size = tex.get_size() * sprite.scale


func _set_instructions_opacity(modulate_a: float, duration: float) -> void:
		if tween_instructions:
			tween_instructions.kill()
			
		tween_instructions = create_tween()
		tween_instructions.tween_property(instructions, "modulate:a", modulate_a, duration)
		await tween_instructions.finished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		_set_instructions_opacity(1, 0.25)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		_set_instructions_opacity(0, 1)

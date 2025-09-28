extends Node2D

@export var frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2(1.0, 1.0)

@onready var sprite: AnimatedSprite2D = find_child('QuestGiverSprite2D')
@onready var collision_shape: CollisionShape2D = find_child('QuestGiverCollisionShape')

func _ready() -> void:
	sprite.sprite_frames = frames
	sprite.scale *= sprite_scale
	_prepare_collisions()

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

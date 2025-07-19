extends CharacterBody2D

func _ready() -> void:
	var sprite = find_child('AnimatedSprite2D')
	
	print('flip_h: ' + str(sprite.flip_h))
	print('rotation: ' + str(sprite.rotation_degrees))

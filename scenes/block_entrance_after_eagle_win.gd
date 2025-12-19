extends StaticBody2D

@onready var collision_shape: CollisionShape2D = find_child('CollisionShape2D')

func _ready() -> void:
	# collision_shape.disabled = true
	GlobalSignals.rodrigo_picked_up.connect(_on_rodrigo_picked_up)

func _make_wall_collidable() -> void:
	collision_shape.disabled = false
	
func _on_rodrigo_picked_up() -> void:
	call_deferred("_make_wall_collidable")
	print("set collision_shape to disabled!")
		
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, 1)

	await fade_tween.finished

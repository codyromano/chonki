extends Node

@onready var star_scene: PackedScene = preload("res://scenes/collectible.tscn")

# Simple throttle function that discards excessive requests
func throttle(request_id: String, callable_to_run: Callable, delay: float = 0.3) -> void:
	# Check if we're still in cooldown period
	if has_meta(request_id):
		return  # Discard this request
	
	# Execute immediately
	callable_to_run.call()
	
	# Set cooldown flag
	set_meta(request_id, true)
	
	# Create timer to clear cooldown
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(func(): 
		remove_meta(request_id)
		timer.queue_free()
	, CONNECT_ONE_SHOT)
	timer.start()

func spawn_star(origin: Node2D, duration: float = 2) -> void:
	# Spawn a star in the goose's place
	var star: Node2D = star_scene.instantiate()
	star.modulate.a = 0
	# star.scale = Vector2(0.5, 0.5)
	
	#  TODO: Change 200px to a logical, dynamic number based
	# on the collectible item size
	# star.global_position = origin.global_position - Vector2(1100, 0)
	star.global_position = origin.global_position - Vector2(250, 250)
	
	origin.get_node('%World2D').add_child(star)
	
	# origin.get_parent().add_child(star)
	
	var tween = create_tween()
	tween.tween_property(star, "modulate:a", 1, duration)
	# tween.tween_property(star, "scale", Vector2(1, 1), duration)
	tween.set_parallel(true)
	await tween.finished


extends NavigationAgent2D

@export var follower: Node2D
@export var target: Node2D
@export var speed: int = 200
@export var desired_distance: float = 50.0

var is_navigation_ready: bool = false

func _ready():
	# Setup NavigationAgent2D
	call_deferred("setup_navigation")

func setup_navigation():
	is_navigation_ready = true
	target_desired_distance = desired_distance
	path_desired_distance = 20.0
	max_speed = speed

func _physics_process(delta):
	if not is_navigation_ready:
		return
		
	if not follower or not target:
		return
		
	var target_pos = target.global_position
	var follower_pos = follower.global_position
	
	print("Follower pos: ", follower_pos, " Target pos: ", target_pos)
	
	# Check if we're close enough to the target
	var dist_to_target = follower_pos.distance_to(target_pos)
	if dist_to_target < 50.0:  # Close enough threshold
		print("Reached target!")
		return
	
	# Simple direct movement towards target for now
	# This bypasses navigation issues and should work for testing
	var direction = (target_pos - follower_pos).normalized()
	var new_pos = follower_pos + direction * speed * delta
	
	follower.global_position = new_pos
	print("Moving follower directly towards target: ", new_pos, " Direction: ", direction)

func set_follower(new_follower: Node2D):
	"""Set the follower node"""
	follower = new_follower

func set_target(new_target: Node2D):
	"""Set the target node"""
	target = new_target

func get_distance_to_target() -> float:
	"""Get the current distance to the target"""
	if follower and target:
		return follower.global_position.distance_to(target.global_position)
	return -1.0

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

func _physics_process(delta):
	if not is_navigation_ready or not follower or not target:
		return
	
	# Set the target position
	target_position = target.global_position
	
	# Check if navigation is finished (reached target)
	if is_navigation_finished():
		return
	
	# Get the next position in the navigation path
	var next_path_position = get_next_path_position()
	var direction = (next_path_position - follower.global_position).normalized()
	
	# Move the follower
	if follower.has_method("set_velocity"):
		# For CharacterBody2D
		follower.velocity = direction * speed
		follower.move_and_slide()
	elif follower.has_method("apply_impulse"):
		# For RigidBody2D
		follower.apply_impulse(direction * speed * delta)
	else:
		# For regular Node2D, move directly
		follower.global_position += direction * speed * delta

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

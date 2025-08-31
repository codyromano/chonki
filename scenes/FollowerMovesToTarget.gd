extends NavigationAgent2D

@export var follower: Node2D
@export var target: Node2D
@export var speed: int = 200
@export var desired_distance: float = 200.0

func _ready():
	# Configure NavigationAgent2D properties
	max_speed = speed
	path_desired_distance = 200.0
	target_desired_distance = desired_distance

func _physics_process(delta):
	if not follower or not target:
		return
		
	# Set the navigation target
	target_position = target.global_position
	
	# Get next path position from NavigationAgent2D
	if is_target_reachable() && not is_navigation_finished():
		var next_path_position = get_next_path_position()
		var current_position = follower.global_position
		
		# Calculate direction to next path point
		var direction = (next_path_position - current_position).normalized()
		
		# Set the follower's velocity instead of directly moving it
		if follower is CharacterBody2D:
			follower.velocity = direction * speed
			follower.move_and_slide()
		elif follower is RigidBody2D:
			follower.linear_velocity = direction * speed
		else:
			# Fallback for other node types - still set position directly
			var new_position = current_position + direction * speed * delta
			follower.global_position = new_position
	else:
		# Stop the follower when navigation is finished
		if follower is CharacterBody2D:
			follower.velocity = Vector2.ZERO
			follower.move_and_slide()
		elif follower is RigidBody2D:
			follower.linear_velocity = Vector2.ZERO

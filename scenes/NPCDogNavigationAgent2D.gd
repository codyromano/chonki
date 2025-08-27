extends NavigationAgent2D

# NPCDogNavigationAgent2D.gd
# Handles NPC dog navigation toward the hay ball

@export var speed: float = 2000.0
@export var target_distance_threshold: float = 50.0
@export var navigation_update_interval: float = 0

@onready var npc_dog: CharacterBody2D = get_parent().get_node("ChaseDog")
@onready var hay_ball: RigidBody2D = get_node("%HayBall") as RigidBody2D
var navigation_timer: float = 0.0

func _ready():
	if not npc_dog:
		print("NPCDogNavigationAgent2D: Parent is not a CharacterBody2D")
		return
	
	if not hay_ball:
		print("NPCDogNavigationAgent2D: Could not find HayBall")
		return
	else:
		print("NPCDogNavigationAgent2D: Found HayBall successfully")
	
	# Set up NavigationAgent2D properties
	target_desired_distance = target_distance_threshold
	path_desired_distance = 20.0

func _physics_process(delta):
	if not npc_dog or not hay_ball:
		print("Error: missing stuff")
		return
	
	navigation_timer += delta
	if navigation_timer >= navigation_update_interval:
		navigation_timer = 0.0
		_update_navigation()

func _update_navigation():
	if not hay_ball or not npc_dog:
		return
	
	var current_distance = npc_dog.global_position.distance_to(hay_ball.global_position)
	
	# If we're close enough, stop moving
	if current_distance <= target_distance_threshold:
		npc_dog.velocity.x = 0
		return
	
	# Use direct movement toward the HayBall
	var direct_direction = (hay_ball.global_position - npc_dog.global_position).normalized()
	
	if abs(direct_direction.x) > 0.1:
		npc_dog.velocity.x = direct_direction.x * speed
		
		# Flip the sprite based on movement direction
		var sprite = npc_dog.get_node("AnimatedSprite2D")
		if sprite:
			sprite.flip_h = direct_direction.x < 0
	else:
		npc_dog.velocity.x = 0
	
	# Move the character
	npc_dog.move_and_slide()

func set_target(new_target: Node2D):
	"""Set a new target for the NPC dog to follow"""
	hay_ball = new_target

func get_distance_to_target() -> float:
	"""Get the current distance to the target"""
	if hay_ball and npc_dog:
		return npc_dog.global_position.distance_to(hay_ball.global_position)
	return -1.0

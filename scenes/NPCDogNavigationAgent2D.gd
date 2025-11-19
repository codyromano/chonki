extends NavigationAgent2D

# NPCDogNavigationAgent2D.gd
# Handles NPC dog navigation toward the hay ball

@export var speed: float = 2000.0
@export var target_distance_threshold: float = 25.0
@export var navigation_update_interval: float = 0

@onready var npc_dog: CharacterBody2D = get_parent().get_node("ChaseDog")
@onready var hay_ball: RigidBody2D = get_node("%HayBall") as RigidBody2D
var navigation_timer: float = 0.0

var enemy: CharacterBody2D
var is_navigation_ready = false

func _ready():
	call_deferred("setup")

func setup() -> void:
	is_navigation_ready = true
	target_desired_distance = 1
	path_desired_distance = 6
	max_speed = speed

func _physics_process(_delta: float) -> void:
	if !is_navigation_ready:
		return
		
	set_target_position(hay_ball.global_position)

	if not is_navigation_finished() && is_target_reachable():
		var next_path_position = get_next_path_position()
		var direction = (next_path_position - npc_dog.global_position).normalized()
		
		npc_dog.velocity.x = direction.x * speed
	else:
		npc_dog.velocity.x = 0

	npc_dog.move_and_slide()

extends Node2D
class_name EnemyAgentNavigation

@export var target: Node2D
@export var enemy: CharacterBody2D
@export var speed: float = 100.0

var agent: NavigationAgent2D

func _ready() -> void:
	# Add agent as child of enemy (required for position syncing)
	agent = enemy.get_node_or_null("NavigationAgent2D")
	if not agent:
		agent = NavigationAgent2D.new()
		enemy.add_child(agent)

	agent.target_desired_distance = 4.0
	agent.path_desired_distance = 0.5
	agent.max_speed = speed

	# ❗️Defer navigation logic to give NavigationServer2D time to initialize
	await get_tree().process_frame

func _physics_process(delta: float) -> void:
	if not target or not enemy or not agent:
		return

	# ✅ Set the target each frame (after nav is initialized)
	agent.set_target_position(target.global_position)

	if not agent.is_navigation_finished():
		var next_pos = agent.get_next_path_position()
		var direction = (next_pos - enemy.global_position).normalized()
		enemy.velocity = direction * speed
		enemy.move_and_slide()

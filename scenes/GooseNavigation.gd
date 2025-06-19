extends NavigationAgent2D

@export var target: Node2D
@export var speed: float = 200.0
@onready var sprite: AnimatedSprite2D = get_parent().find_child('AnimatedSprite2D')

var enemy: CharacterBody2D

func _ready():
	# This script must be a child of the enemy
	enemy = get_parent() as CharacterBody2D
	if not enemy:
		push_error("NavigationAgent2D must be a child of a CharacterBody2D.")
		set_process(false)
		return
	
	call_deferred("setup")

func setup() -> void:
	target_desired_distance = 1
	path_desired_distance = 6
	max_speed = speed

func _physics_process(delta: float) -> void:
	# NavigationAgent2D gets its position from its parent (enemy)
	set_target_position(target.find_child('ChonkiCharacter').global_position)

	if not is_navigation_finished():
		var next_path_position = get_next_path_position()
		var direction = (next_path_position - enemy.global_position).normalized()
		
		direction.y = 0
		# enemy.velocity = direction * speed
		enemy.velocity.x = direction.x * speed
		
		sprite.flip_h = direction.x < 0
			
		enemy.move_and_slide()
	else:
		pass
		enemy.velocity.x = 0

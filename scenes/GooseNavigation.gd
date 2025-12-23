extends NavigationAgent2D

@export var speed: float = 200.0
var parent: CharacterBody2D
var sprite: AnimatedSprite2D

var target: Node2D
var enemy: CharacterBody2D
var is_navigation_ready = false

func _ready():
	parent = get_parent() as CharacterBody2D
	if parent:
		sprite = parent.find_child('AnimatedSprite2D')
	
	target = get_tree().current_scene.find_child("GrownUpChonki", true, false)
	
	if !target:
		push_error("GooseNavigation could not find GrownUpChonki node")
		set_process(false)
		return
		
	enemy = get_parent() as CharacterBody2D
	if not enemy:
		push_error("NavigationAgent2D must be a child of a CharacterBody2D.")
		set_process(false)
		return
	
	call_deferred("setup")

func setup() -> void:
	is_navigation_ready = true
	target_desired_distance = 1
	path_desired_distance = 6
	max_speed = speed

func _physics_process(_delta: float) -> void:
	if !is_navigation_ready:
		return
		
	# NavigationAgent2D gets its position from its parent (enemy)
	set_target_position(target.find_child('ChonkiCharacter').global_position)

	if not is_navigation_finished() && is_target_reachable() && !parent.is_injured():
		var next_path_position = get_next_path_position()
		var direction = (next_path_position - enemy.global_position).normalized()
		
		direction.y = 0
		enemy.velocity.x = direction.x * speed
		# enemy.move_and_slide()
	# else:
		# enemy.velocity.x = 0
		# enemy.velocity.y = 2000

	enemy.move_and_slide()

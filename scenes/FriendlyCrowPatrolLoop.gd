extends "res://scenes/NPCLinearPatrolLoop.gd"

@export var branch_scene: PackedScene
@export var branch_initial_position: Vector2
@export var branch_initial_rotation: float

var current_branch: Node = null

func _ready():
	super()
	# Instantiate the first branch
	_respawn_branch()
	GlobalSignals.biker_cleaned_up_branch.connect(_on_biker_cleaned_up_branch)

func _on_biker_cleaned_up_branch():
	_respawn_branch()

func _respawn_branch():
	if branch_scene:
		# Clean up the old branch if it exists
		if is_instance_valid(current_branch):
			current_branch.queue_free()

		var new_branch = branch_scene.instantiate()
		body.add_child(new_branch)
		new_branch.position = branch_initial_position
		new_branch.rotation = branch_initial_rotation
		current_branch = new_branch

func _on_change_direction(_moving_toward_end: bool, crow_sprite: AnimatedSprite2D) -> void:
	# Flip the crow when returning to the start marker
	crow_sprite.flip_h = !crow_sprite.flip_h

	if !is_instance_valid(current_branch):
		return
	
	# Flip the branch's position based on the crow's direction
	if crow_sprite.flip_h:
		current_branch.position.x = -branch_initial_position.x
		current_branch.rotation = -branch_initial_rotation
	else:
		current_branch.position.x = branch_initial_position.x
		current_branch.rotation = branch_initial_rotation

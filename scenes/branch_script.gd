extends CharacterBody2D

const GRAVITY = 20000.0

var is_falling = false

func _ready():
	GlobalSignals.crow_dropped_branch.connect(_on_crow_dropped_branch)

func _physics_process(delta):
	if is_falling:
		velocity.y += GRAVITY * delta
		move_and_slide()

func _on_crow_dropped_branch():
	is_falling = true
	call_deferred("_reparent_to_world")

func _reparent_to_world():
	# Reparent to the main world so it doesn't move with the crow
	var current_parent = get_parent()
	if current_parent:
		var world = get_tree().current_scene.get_node("%World2D")
		if world:
			var new_transform = self.global_transform
			current_parent.remove_child(self)
			world.add_child(self)
			self.global_transform = new_transform

extends CharacterBody2D

const GRAVITY = 20000.0

@export var target_marker: Marker2D

var is_falling = false

func _ready():
	GlobalSignals.crow_dropped_branch.connect(_on_crow_dropped_branch)
	GlobalSignals.biker_cleaned_up_branch.connect(_on_biker_cleaned_up_branch)

func _on_biker_cleaned_up_branch() -> void:
	call_deferred("queue_free")
	
func _physics_process(delta):
	if is_falling:
		if !is_on_floor():
			velocity.y += GRAVITY * delta
	else:
		global_transform = target_marker.global_transform
		
	move_and_slide()

func _on_crow_dropped_branch():
	is_falling = true


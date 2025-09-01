extends CharacterBody2D

@export var flip_h: bool = false

## Horse script
## 
## Handles horse behavior including the buck animation triggered by
## the horse_buck trampoline

var original_rotation: float = 0.0
var is_bucking: bool = false

func _ready():
	$AnimatedSprite2D.flip_h = flip_h 
	
	# Store the original rotation
	original_rotation = rotation_degrees
	
	# Connect to the horse_buck signal
	GlobalSignals.connect("horse_buck", _on_horse_buck)

func _on_horse_buck():
	# Prevent multiple buck animations from overlapping
	if is_bucking:
		return
		
	is_bucking = true
	
	# Create a tween for smooth animation
	var tween = create_tween()
	
	# First rotate 40 degrees to the left (counter-clockwise)
	# Then rotate back to original position
	# Each part takes 0.5 seconds for a total of 1 second
	tween.tween_property(self, "rotation_degrees", original_rotation - 40.0, 0.5)
	tween.tween_property(self, "rotation_degrees", original_rotation, 0.5)
	
	# When animation is complete, reset the bucking flag
	tween.tween_callback(func(): is_bucking = false)

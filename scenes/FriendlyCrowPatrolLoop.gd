extends "res://scenes/NPCLinearPatrolLoop.gd"

func _ready():
	super()

func _on_change_direction(_moving_toward_end: bool, crow_sprite: AnimatedSprite2D) -> void:
	# Flip the crow when returning to the start marker
	crow_sprite.flip_h = !crow_sprite.flip_h
	

#var crow_body: CharacterBody2D = crow_sprite.get_parent()
#var branch: CharacterBody2D = crow_body.find_child('Branch')
#var branch_marker: Marker2D = crow_body.find_child('BranchMarker')
#
## Flip the branch's position based on the crow's direction
#if crow_sprite.flip_h:
#branch.position.x = -branch_marker.position.x
#branch.rotation = -branch.rotation
	#else:
#branch.position.x = branch_marker.position.x
#branch.rotation = branch.rotation

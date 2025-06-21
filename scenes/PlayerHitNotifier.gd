extends Node2D

@export var enemy: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Make the on_child_entered_tree function fire when
	# any object collides with enemy
	pass
	
func on_child_entered_tree(collided_with: Node2D) -> void:
	if collided_with.name == "Chonki":
		GlobalSignals.player_hit.emit()

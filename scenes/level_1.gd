extends Node2D

@onready var leaf_system = find_child('Leaves')

func _ready():
	# Apply a preset for quick setup
	leaf_system.apply_preset("gentle_breeze")
	
	# Or customize manually
	leaf_system.leaf_count = 40
	leaf_system.upward_force = 25.0
	leaf_system.wind_strength = Vector2(20.0, 5.0)

func _on_wind_change():
	# Example: Change wind based on game events
	var new_wind = Vector2(randf_range(-30, 30), randf_range(-10, 10))
	leaf_system.set_wind_direction(new_wind)

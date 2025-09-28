extends Node2D

@onready var leaf_system = find_child('Leaves')

func _ready():
	pass
	# Apply a preset for quick setup
	# leaf_system.apply_preset("strong_wind")

func _on_wind_change():
	pass
	# Example: Change wind based on game events
	# var new_wind = Vector2(randf_range(-30, 30), randf_range(-10, 10))
	# leaf_system.set_wind_direction(new_wind)

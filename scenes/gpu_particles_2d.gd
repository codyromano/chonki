# FloatingLeavesParticles.gd
extends GPUParticles2D

## Exported variables for easy tweaking in the editor
@export_group("Leaf Behavior")
@export var leaf_count: int = 50
@export var leaf_lifetime: float = 15.0
@export var upward_force: float = 20.0
@export var wind_strength: Vector2 = Vector2(15.0, 0.0)

@export_group("Movement Variation")
@export var initial_velocity_range: Vector2 = Vector2(10.0, 30.0)
@export var gravity_strength: float = -5.0
@export var angular_velocity_range: Vector2 = Vector2(-90.0, 90.0)

@export_group("Visual Settings")
@export var leaf_texture: Texture2D
@export var scale_range: Vector2 = Vector2(0.3, 1.2)
@export var color_variation: bool = true

@export_group("Wind Effects")
@export var enable_wind_zones: bool = true
@export var wind_turbulence: float = 10.0

var time_passed: float = 0.0

func _ready():
	setup_particle_system()

func setup_particle_system():
	# Basic particle settings
	emitting = true
	amount = leaf_count
	lifetime = leaf_lifetime
	
	# Create and configure the process material
	process_material = ParticleProcessMaterial.new()
	
	# Set the texture if provided
	if leaf_texture:
		texture = leaf_texture
	
	configure_emission()
	configure_movement()
	configure_appearance()
	configure_physics()
	
	# Apply the material
	process_material_override = process_material

func configure_emission():
	"""Configure how and where particles spawn"""
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	# Spawn across the width of the screen, slightly below
	process_material.emission_box_extents = Vector3(400, 10, 0)
	
	# Spawn rate
	process_material.emission_rate = leaf_count / leaf_lifetime

func configure_movement():
	"""Set up the floating and wind movement"""
	# Base direction (slightly upward)
	process_material.direction = Vector3(wind_strength.x, -upward_force, 0)
	
	# Initial velocity
	process_material.initial_velocity_min = initial_velocity_range.x
	process_material.initial_velocity_max = initial_velocity_range.y
	
	# Gravity (negative for upward force)
	process_material.gravity = Vector3(0, gravity_strength, 0)
	
	# Rotation
	process_material.angular_velocity_min = angular_velocity_range.x
	process_material.angular_velocity_max = angular_velocity_range.y

func configure_appearance():
	"""Configure visual aspects of the leaves"""
	# Scale variation
	process_material.scale_min = scale_range.x
	process_material.scale_max = scale_range.y
	
	# Color variation for autumn leaves
	if color_variation:
		# Autumn leaf colors
		process_material.color = Color.WHITE
		process_material.color_ramp = create_autumn_color_ramp()
	
	# Fade out over time
	var alpha_curve = Curve.new()
	alpha_curve.add_point(0.0, 1.0)  # Start fully visible
	alpha_curve.add_point(0.8, 1.0)  # Stay visible most of the time
	alpha_curve.add_point(1.0, 0.0)  # Fade out at the end
	
	process_material.alpha_curve = alpha_curve

func configure_physics():
	"""Add turbulence and variation for realistic movement"""
	# Add some randomness to make leaves flutter
	process_material.turbulence_enabled = enable_wind_zones
	if enable_wind_zones:
		process_material.turbulence_strength = wind_turbulence
		process_material.turbulence_scale = 2.0
		process_material.turbulence_influence_min = 0.1
		process_material.turbulence_influence_max = 0.3

func create_autumn_color_ramp() -> Gradient:
	"""Create a gradient with autumn leaf colors"""
	var gradient = Gradient.new()
	
	# Autumn colors: green -> yellow -> orange -> red -> brown
	gradient.colors = [
		Color(0.2, 0.8, 0.2),    # Green
		Color(1.0, 1.0, 0.3),    # Yellow
		Color(1.0, 0.6, 0.2),    # Orange
		Color(0.8, 0.3, 0.2),    # Red
		Color(0.6, 0.4, 0.2)     # Brown
	]
	
	gradient.offsets = [0.0, 0.2, 0.4, 0.7, 1.0]
	
	return gradient

func _process(delta):
	"""Update wind effects over time"""
	time_passed += delta
	
	# Create dynamic wind by modifying gravity
	if enable_wind_zones:
		var wind_variation = sin(time_passed * 0.5) * 5.0
		process_material.gravity = Vector3(wind_variation, gravity_strength, 0)

# Public methods to control the effect

func start_leaf_effect():
	"""Start emitting leaves"""
	emitting = true

func stop_leaf_effect():
	"""Stop emitting new leaves (existing ones will finish their lifecycle)"""
	emitting = false

func clear_all_leaves():
	"""Immediately clear all leaves"""
	restart()

func set_wind_direction(direction: Vector2):
	"""Change wind direction dynamically"""
	wind_strength = direction
	if process_material:
		process_material.direction = Vector3(direction.x, -upward_force, 0)

func set_leaf_density(density: int):
	"""Change the number of leaves"""
	leaf_count = density
	amount = leaf_count
	if process_material:
		process_material.emission_rate = float(leaf_count) / leaf_lifetime

# Helper function to create different leaf presets
func apply_preset(preset_name: String):
	"""Apply predefined settings for different scenarios"""
	match preset_name:
		"gentle_breeze":
			upward_force = 15.0
			wind_strength = Vector2(10.0, 0.0)
			wind_turbulence = 5.0
			leaf_count = 30
		
		"strong_wind":
			upward_force = 5.0
			wind_strength = Vector2(40.0, 10.0)
			wind_turbulence = 25.0
			leaf_count = 80
		
		"magical_float":
			upward_force = 30.0
			wind_strength = Vector2(5.0, 0.0)
			wind_turbulence = 15.0
			gravity_strength = -15.0
			leaf_count = 25
		
		"leaf_storm":
			upward_force = 10.0
			wind_strength = Vector2(30.0, 15.0)
			wind_turbulence = 35.0
			leaf_count = 150
	
	# Reapply settings
	setup_particle_system()

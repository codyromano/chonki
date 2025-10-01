# FloatingLeavesParticles.gd
extends GPUParticles2D

## Exported variables for easy tweaking in the editor
@export_group("Leaf Behavior")
@export var max_leaves: int = 2  # Maximum leaves visible at once
@export var leaf_lifetime: float = 8.0  # Shorter lifetime to prevent accumulation
@export var upward_force: float = 20.0
@export var wind_strength: Vector2 = Vector2(15.0, 0.0)

# Compatibility property for old scenes
@export var leaf_count: int = 2:
	set(value):
		max_leaves = value

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

var particle_material: ParticleProcessMaterial
var time_passed: float = 0.0

func _ready():
	setup_particle_system()

func setup_particle_system():
	# Basic particle settings - use very low emission rate
	emitting = true
	amount = max_leaves  # Maximum particles that can exist at once
	lifetime = leaf_lifetime
	
	# The key is controlling the emission rate to be much lower than amount/lifetime
	# Normal rate would be amount/lifetime = 2/8 = 0.25 particles/second
	# We want much slower, so we'll use explosiveness to create bursts
	explosiveness = 1.0  # Emit all particles at once, then wait
	
	# Create and configure the process material
	particle_material = ParticleProcessMaterial.new()
	
	# Set the texture if provided
	if leaf_texture:
		texture = leaf_texture
	
	configure_emission()
	configure_movement()
	configure_appearance()
	configure_physics()
	
	# Apply the material
	process_material = particle_material

func configure_emission():
	"""Configure how and where particles spawn"""
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	# Spawn across the width of the screen, slightly below
	particle_material.emission_box_extents = Vector3(400, 10, 0)

func configure_movement():
	"""Set up the floating and wind movement"""
	# Base direction (slightly upward with wind)
	particle_material.direction = Vector3(wind_strength.x, -upward_force, 0)
	
	# Initial velocity using the new API
	particle_material.set_param_min(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, initial_velocity_range.x)
	particle_material.set_param_max(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, initial_velocity_range.y)
	
	# Gravity (negative for upward force)
	particle_material.gravity = Vector3(0, gravity_strength, 0)
	
	# Angular velocity (rotation)
	particle_material.set_param_min(ParticleProcessMaterial.PARAM_ANGULAR_VELOCITY, deg_to_rad(angular_velocity_range.x))
	particle_material.set_param_max(ParticleProcessMaterial.PARAM_ANGULAR_VELOCITY, deg_to_rad(angular_velocity_range.y))

func configure_appearance():
	"""Configure visual aspects of the leaves"""
	# Scale variation
	particle_material.set_param_min(ParticleProcessMaterial.PARAM_SCALE, scale_range.x)
	particle_material.set_param_max(ParticleProcessMaterial.PARAM_SCALE, scale_range.y)
	
	# Color variation for autumn leaves
	if color_variation:
		particle_material.color = Color.WHITE
		var color_ramp_texture = create_autumn_color_ramp()
		particle_material.color_ramp = color_ramp_texture
	
	# Fade out over time
	var alpha_curve = Curve.new()
	alpha_curve.add_point(0.0, 1.0)  # Start fully visible
	alpha_curve.add_point(0.8, 1.0)  # Stay visible most of the time
	alpha_curve.add_point(1.0, 0.0)  # Fade out at the end
	
	var alpha_curve_texture = CurveTexture.new()
	alpha_curve_texture.curve = alpha_curve
	particle_material.alpha_curve = alpha_curve_texture
	
	# High lifetime randomness to spread out emissions
	particle_material.lifetime_randomness = 0.6

func configure_physics():
	"""Add turbulence and variation for realistic movement"""
	# Add some randomness to make leaves flutter
	particle_material.turbulence_enabled = enable_wind_zones
	if enable_wind_zones:
		particle_material.turbulence_noise_strength = wind_turbulence
		particle_material.turbulence_noise_scale = 2.0
		particle_material.set_param_min(ParticleProcessMaterial.PARAM_TURB_VEL_INFLUENCE, 0.1)
		particle_material.set_param_max(ParticleProcessMaterial.PARAM_TURB_VEL_INFLUENCE, 0.3)
		
		# Create turbulence influence curve
		var turb_curve = Curve.new()
		turb_curve.add_point(Vector2(0.0, 0.2))
		turb_curve.add_point(Vector2(0.5, 1.0))
		turb_curve.add_point(Vector2(1.0, 0.3))
		
		var turb_curve_texture = CurveTexture.new()
		turb_curve_texture.curve = turb_curve
		particle_material.set_param_texture(ParticleProcessMaterial.PARAM_TURB_INFLUENCE_OVER_LIFE, turb_curve_texture)

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
	if enable_wind_zones and particle_material:
		var wind_variation = sin(time_passed * 0.5) * 5.0
		particle_material.gravity = Vector3(wind_variation, gravity_strength, 0)

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
	if particle_material:
		particle_material.direction = Vector3(direction.x, -upward_force, 0)

func set_leaf_density(density: int):
	"""Change the number of leaves (now controls max_leaves)"""
	max_leaves = density
	amount = max_leaves

# Helper function to create different leaf presets
func apply_preset(preset_name: String):
	"""Apply predefined settings for different scenarios"""
	match preset_name:
		"gentle_breeze":
			upward_force = 15.0
			wind_strength = Vector2(10.0, 0.0)
			wind_turbulence = 5.0
			max_leaves = 1
			leaf_lifetime = 10.0
		
		"strong_wind":
			upward_force = 5.0
			wind_strength = Vector2(40.0, 10.0)
			wind_turbulence = 25.0
			max_leaves = 2
			leaf_lifetime = 8.0
		
		"magical_float":
			upward_force = 30.0
			wind_strength = Vector2(5.0, 0.0)
			wind_turbulence = 15.0
			gravity_strength = -15.0
			max_leaves = 1
			leaf_lifetime = 12.0
		
		"leaf_storm":
			upward_force = 10.0
			wind_strength = Vector2(30.0, 15.0)
			wind_turbulence = 35.0
			max_leaves = 2
			leaf_lifetime = 6.0
	
	# Reapply settings
	setup_particle_system()

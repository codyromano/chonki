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
	material = ParticleProcessMaterial.new()
	
	# Set the texture if provided
	if leaf_texture:
		texture = leaf_texture
	
	configure_emission()
	configure_movement()
	configure_appearance()
	configure_physics()
	
	# Apply the material
	process_material = material

func configure_emission():
	"""Configure how and where particles spawn"""
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	# Spawn across the width of the screen, slightly below
	material.emission_box_extents = Vector3(400, 10, 0)

func configure_movement():
	"""Set up the floating and wind movement"""
	# Base direction (slightly upward with wind)
	material.direction = Vector3(wind_strength.x, -upward_force, 0)
	
	# Initial velocity using the new API
	material.set_param_min(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, initial_velocity_range.x)
	material.set_param_max(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, initial_velocity_range.y)
	
	# Gravity (negative for upward force)
	material.gravity = Vector3(0, gravity_strength, 0)
	
	# Angular velocity (rotation)
	material.set_param_min(ParticleProcessMaterial.PARAM_ANGULAR_VELOCITY, deg_to_rad(angular_velocity_range.x))
	material.set_param_max(ParticleProcessMaterial.PARAM_ANGULAR_VELOCITY, deg_to_rad(angular_velocity_range.y))

func configure_appearance():
	"""Configure visual aspects of the leaves"""
	# Scale variation
	material.set_param_min(ParticleProcessMaterial.PARAM_SCALE, scale_range.x)
	material.set_param_max(ParticleProcessMaterial.PARAM_SCALE, scale_range.y)
	
	# Color variation for autumn leaves
	if color_variation:
		material.color = Color.WHITE
		var color_ramp_texture = create_autumn_color_ramp()
		material.color_ramp = color_ramp_texture
	
	# Fade out over time using alpha curve
	var alpha_curve = Curve.new()
	alpha_curve.add_point(Vector2(0.0, 1.0))  # Start fully visible
	alpha_curve.add_point(Vector2(0.8, 1.0))  # Stay visible most of the time
	alpha_curve.add_point(Vector2(1.0, 0.0))  # Fade out at the end
	
	var alpha_curve_texture = CurveTexture.new()
	alpha_curve_texture.curve = alpha_curve
	material.alpha_curve = alpha_curve_texture

func configure_physics():
	"""Add turbulence and variation for realistic movement"""
	# Add some randomness to make leaves flutter
	material.turbulence_enabled = enable_wind_zones
	if enable_wind_zones:
		material.turbulence_noise_strength = wind_turbulence
		material.turbulence_noise_scale = 2.0
		material.set_param_min(ParticleProcessMaterial.PARAM_TURB_VEL_INFLUENCE, 0.1)
		material.set_param_max(ParticleProcessMaterial.PARAM_TURB_VEL_INFLUENCE, 0.3)
		
		# Create turbulence influence curve
		var turb_curve = Curve.new()
		turb_curve.add_point(Vector2(0.0, 0.2))
		turb_curve.add_point(Vector2(0.5, 1.0))
		turb_curve.add_point(Vector2(1.0, 0.3))
		
		var turb_curve_texture = CurveTexture.new()
		turb_curve_texture.curve = turb_curve
		material.set_param_texture(ParticleProcessMaterial.PARAM_TURB_INFLUENCE_OVER_LIFE, turb_curve_texture)

func create_autumn_color_ramp() -> GradientTexture1D:
	"""Create a gradient texture with autumn leaf colors"""
	var gradient = Gradient.new()
	
	# Set colors one by one using set_color method
	gradient.set_color(0, Color(0.2, 0.8, 0.2))    # Green
	gradient.add_point(0.2, Color(1.0, 1.0, 0.3))  # Yellow
	gradient.add_point(0.4, Color(1.0, 0.6, 0.2))  # Orange
	gradient.add_point(0.7, Color(0.8, 0.3, 0.2))  # Red
	gradient.add_point(1.0, Color(0.6, 0.4, 0.2))  # Brown
	
	# Create gradient texture
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	
	return gradient_texture

func _process(delta):
	"""Update wind effects over time"""
	time_passed += delta
	
	# Create dynamic wind by modifying gravity
	if enable_wind_zones and material:
		var wind_variation = sin(time_passed * 0.5) * 5.0
		material.gravity = Vector3(wind_variation, gravity_strength, 0)

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
	if material:
		material.direction = Vector3(direction.x, -upward_force, 0)

func set_leaf_density(density: int):
	"""Change the number of leaves"""
	leaf_count = density
	amount = leaf_count

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

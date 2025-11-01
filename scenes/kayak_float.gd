extends StaticBody2D

# Floating animation parameters
@export var float_amplitude: float = 10.0  # How far up/down to move (in pixels)
@export var float_speed: float = 1.0  # Speed of the floating motion

# Rotation parameters
@export var rotation_acceleration: float = 1.25  # How fast the rotation speeds up (2.5x faster)
@export var flip_angle: float = 180.0  # Angle at which kayak is considered flipped (degrees)
@export var return_speed: float = 2.0  # How fast it returns to level when balanced

var time_passed: float = 0.0
var initial_position: Vector2
var rotation_velocity: float = 0.0  # Current rotation speed
var tip_area_left: Area2D
var tip_area_right: Area2D
var gus_on_left: bool = false
var gus_on_right: bool = false
var is_flipped: bool = false

func _ready():
	# Store the initial position to return to it
	initial_position = position
	
	# Get references to the tip areas
	tip_area_left = $TipAreaLeft
	tip_area_right = $TipAreaRight
	
	# Connect to the collision signals (check if not already connected)
	if tip_area_left:
		if not tip_area_left.body_entered.is_connected(_on_tip_area_left_body_entered):
			tip_area_left.body_entered.connect(_on_tip_area_left_body_entered)
		if not tip_area_left.body_exited.is_connected(_on_tip_area_left_body_exited):
			tip_area_left.body_exited.connect(_on_tip_area_left_body_exited)
	
	if tip_area_right:
		if not tip_area_right.body_entered.is_connected(_on_tip_area_right_body_entered):
			tip_area_right.body_entered.connect(_on_tip_area_right_body_entered)
		if not tip_area_right.body_exited.is_connected(_on_tip_area_right_body_exited):
			tip_area_right.body_exited.connect(_on_tip_area_right_body_exited)

func _process(delta):
	# Increment time
	time_passed += delta * float_speed
	
	# Calculate the vertical offset using a quadratic function
	# Use a parabola that oscillates: create a repeating pattern
	var cycle = fmod(time_passed, 2.0)  # 2 second cycle
	var normalized = cycle / 2.0  # Normalize to 0-1
	# Quadratic function: -(x - 0.5)^2 + 0.25, scaled and offset
	var quadratic_value = -(normalized - 0.5) * (normalized - 0.5) + 0.25
	var vertical_offset = (quadratic_value * 4.0 - 0.5) * float_amplitude
	
	# Apply the floating motion
	position.y = initial_position.y + vertical_offset
	
	# Determine rotation direction based on which side Gus is on
	if gus_on_left and not gus_on_right:
		# Gus on left - rotate left (counterclockwise)
		rotation_velocity -= rotation_acceleration * delta
	elif gus_on_right and not gus_on_left:
		# Gus on right - rotate right (clockwise)
		rotation_velocity += rotation_acceleration * delta
	elif gus_on_left and gus_on_right:
		# Both sides - slow down rotation
		rotation_velocity = lerp(rotation_velocity, 0.0, return_speed * delta)
	else:
		# No one on kayak - return to level
		rotation_velocity = lerp(rotation_velocity, 0.0, return_speed * delta)
		# Also return rotation to 0 if kayak is upright
		if abs(rotation) < deg_to_rad(flip_angle):
			rotation = lerp_angle(rotation, 0.0, return_speed * delta)
	
	# Apply rotation velocity
	rotation += rotation_velocity * delta
	
	# Check if kayak has flipped (reached flip angle)
	var current_angle_deg = abs(rad_to_deg(rotation))
	if current_angle_deg >= flip_angle and not is_flipped:
		is_flipped = true
		# Kayak flipped! Gus should fall
		# The collision will naturally make Gus fall off

func _on_tip_area_left_body_entered(body):
	# Check if it's Gus (you may need to adjust the check based on your character's name/group)
	if body.name.contains("Chonki") or body.is_in_group("player"):
		gus_on_left = true

func _on_tip_area_left_body_exited(body):
	if body.name.contains("Chonki") or body.is_in_group("player"):
		gus_on_left = false

func _on_tip_area_right_body_entered(body):
	if body.name.contains("Chonki") or body.is_in_group("player"):
		gus_on_right = true

func _on_tip_area_right_body_exited(body):
	if body.name.contains("Chonki") or body.is_in_group("player"):
		gus_on_right = false

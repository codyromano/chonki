extends GutTest

# Test suite for the kayak floating and rotation mechanics
# Tests the kayak_float.gd script behavior

var kayak_scene = preload("res://scenes/kayak_float.gd")
var kayak: StaticBody2D
var mock_player: CharacterBody2D

func before_each():
	# Setup - create a new kayak instance before each test
	kayak = StaticBody2D.new()
	kayak.set_script(kayak_scene)
	
	# Create mock tip areas
	var tip_left = Area2D.new()
	tip_left.name = "TipAreaLeft"
	kayak.add_child(tip_left)
	
	var tip_right = Area2D.new()
	tip_right.name = "TipAreaRight"
	kayak.add_child(tip_right)
	
	# Create mock player
	mock_player = CharacterBody2D.new()
	mock_player.name = "GrownUpChonki"
	
	# Add to scene tree so _ready is called
	add_child_autofree(kayak)
	add_child_autofree(mock_player)
	
	# Manually call _ready to initialize
	kayak._ready()

func after_each():
	# Cleanup happens automatically with autofree
	kayak = null
	mock_player = null

# Test: Initial state
func test_kayak_starts_at_zero_rotation():
	assert_eq(kayak.rotation, 0.0, "Kayak should start with zero rotation")

func test_kayak_stores_initial_position():
	var initial_pos = kayak.position
	assert_eq(kayak.initial_position, initial_pos, "Should store initial position")

# Test: Floating motion
func test_kayak_floats_up_and_down():
	var initial_y = kayak.position.y
	
	# Simulate time passing
	kayak._process(0.5)
	
	# Y position should have changed (floating)
	assert_ne(kayak.position.y, initial_y, "Kayak should move vertically when floating")

func test_floating_respects_amplitude():
	kayak.float_amplitude = 50.0
	var initial_y = kayak.initial_position.y
	
	# Process through some time
	for i in range(10):
		kayak._process(0.1)
	
	var max_displacement = abs(kayak.position.y - initial_y)
	assert_lte(max_displacement, kayak.float_amplitude + 1.0, 
		"Vertical displacement should not exceed amplitude")

# Test: Rotation when player on left
func test_rotation_when_player_on_left():
	# Simulate player entering left tip area
	kayak._on_tip_area_left_body_entered(mock_player)
	
	assert_true(kayak.gus_on_left, "Should detect player on left")
	
	# Process some frames
	for i in range(10):
		kayak._process(0.1)
	
	# Rotation should be negative (counterclockwise)
	assert_lt(kayak.rotation, 0.0, "Kayak should rotate left (negative) when player on left side")

# Test: Rotation when player on right
func test_rotation_when_player_on_right():
	# Simulate player entering right tip area
	kayak._on_tip_area_right_body_entered(mock_player)
	
	assert_true(kayak.gus_on_right, "Should detect player on right")
	
	# Process some frames
	for i in range(10):
		kayak._process(0.1)
	
	# Rotation should be positive (clockwise)
	assert_gt(kayak.rotation, 0.0, "Kayak should rotate right (positive) when player on right side")

# Test: Rotation acceleration
func test_rotation_accelerates_over_time():
	kayak._on_tip_area_left_body_entered(mock_player)
	
	# Get rotation after short time
	kayak._process(0.1)
	var early_velocity = kayak.rotation_velocity
	
	# Process more time
	for i in range(10):
		kayak._process(0.1)
	
	var later_velocity = kayak.rotation_velocity
	
	# Velocity should have increased (become more negative)
	assert_lt(later_velocity, early_velocity, "Rotation should accelerate over time")

# Test: Balanced state (player on both sides)
func test_balanced_when_player_on_both_sides():
	# Put player on both sides
	kayak._on_tip_area_left_body_entered(mock_player)
	kayak._on_tip_area_right_body_entered(mock_player)
	
	# Give it some initial rotation velocity
	kayak.rotation_velocity = 1.0
	
	# Process frames
	for i in range(20):
		kayak._process(0.1)
	
	# Rotation velocity should decrease toward zero
	assert_almost_eq(kayak.rotation_velocity, 0.0, 0.5, 
		"Rotation should slow down when balanced on both sides")

# Test: Return to level when player leaves
func test_returns_to_level_when_player_leaves():
	# Tilt the kayak
	kayak._on_tip_area_left_body_entered(mock_player)
	for i in range(10):
		kayak._process(0.1)
	
	# Player leaves
	kayak._on_tip_area_left_body_exited(mock_player)
	
	var rotation_before = abs(kayak.rotation)
	
	# Process more time
	for i in range(30):
		kayak._process(0.1)
	
	var rotation_after = abs(kayak.rotation)
	
	# Rotation should decrease toward zero
	assert_lt(rotation_after, rotation_before, "Kayak should return toward level when player leaves")

# Test: Flip detection
func test_flip_detected_at_180_degrees():
	kayak._on_tip_area_right_body_entered(mock_player)
	kayak.rotation_acceleration = 5.0  # Speed up for test
	
	# Process until flipped
	for i in range(100):
		kayak._process(0.1)
		if kayak.is_flipped:
			break
	
	assert_true(kayak.is_flipped, "Should detect flip at 180 degrees")
	var angle_deg = abs(rad_to_deg(kayak.rotation))
	assert_gte(angle_deg, kayak.flip_angle, "Should flip at or past flip_angle")

# Test: Player detection by name
func test_detects_player_by_name_containing_chonki():
	var player_variant = CharacterBody2D.new()
	player_variant.name = "SomeChonkiNode"
	add_child_autofree(player_variant)
	
	kayak._on_tip_area_left_body_entered(player_variant)
	assert_true(kayak.gus_on_left, "Should detect any node with 'Chonki' in name")

# Test: Doesn't detect non-player bodies
func test_ignores_non_player_bodies():
	var other_body = StaticBody2D.new()
	other_body.name = "RandomObject"
	add_child_autofree(other_body)
	
	kayak._on_tip_area_left_body_entered(other_body)
	assert_false(kayak.gus_on_left, "Should not detect non-player bodies")

# Test: Export variables are accessible
func test_export_variables_are_set():
	assert_not_null(kayak.float_amplitude, "float_amplitude should be accessible")
	assert_not_null(kayak.float_speed, "float_speed should be accessible")
	assert_not_null(kayak.rotation_acceleration, "rotation_acceleration should be accessible")
	assert_not_null(kayak.flip_angle, "flip_angle should be accessible")
	assert_not_null(kayak.return_speed, "return_speed should be accessible")

# Test: Rotation velocity starts at zero
func test_rotation_velocity_starts_at_zero():
	assert_eq(kayak.rotation_velocity, 0.0, "Rotation velocity should start at zero")

# Test: Multiple cycles of floating
func test_floating_continues_over_multiple_cycles():
	var positions = []
	
	# Record positions over time
	for i in range(50):
		kayak._process(0.1)
		positions.append(kayak.position.y)
	
	# Check that we have variation (floating is happening)
	var min_y = positions.min()
	var max_y = positions.max()
	var range_y = max_y - min_y
	
	assert_gt(range_y, 0.0, "Kayak should continue floating over time")

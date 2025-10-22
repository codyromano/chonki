extends Node2D

# Start in the swiveled state
@export var is_swiveled: bool = false

# Initial rotation in degrees (before swiveling)
@export var initial_rotation_degrees: float = 0.0

# Degrees to rotate when swiveling (positive for clockwise, negative for counter-clockwise)
@export var swivel_rotation_degrees: float = -80.0

# Configure the speed of the swiveling animation
@export var swivel_animation_duration: float = 1

# Which edge of the sprite to use as anchor point when rotating
# 1.0 = right edge, -1.0 = left edge, 0.0 = center
@export var anchor_point_offset: float = 1.0

# Rotation of the collision shape rectangle (for controlling one-way collision direction)
@export var collision_shape_rectangle_rotation: float = 0.0

# Should the branch collisions be disabled initially
# @export var is_collision_disabled: bool = false

@export var is_disabled_on_swivel: bool = true

@onready var collision_shape: StaticBody2D = find_child('CollisionShape2D')
@onready var sprite: Sprite2D = find_child('SwivelBranchSprite')
@onready var collision_shape_rect: CollisionShape2D = find_child('BranchCollisionShape')

var initial_position: Vector2 = Vector2.ZERO
var is_animating: bool = false
var swivel_tween: Tween
var debug_timer: float = 0.0
var debug_toggle_interval: float = 4.0

func _process(_delta) -> void:
	# Apply the collision shape rectangle rotation from the export variable
	collision_shape_rect.rotation_degrees = collision_shape_rectangle_rotation
	# collision_shape_rect.disabled = (is_disabled_on_swivel && is_swiveled) || (!is_disabled_on_swivel && !is_swiveled)
		
func _ready() -> void:	
	initial_position = collision_shape.position
	
	# Set the initial rotation from the export variable
	collision_shape.rotation_degrees = initial_rotation_degrees
	
	GlobalSignals.lever_status_changed.connect(_on_lever_status_changed)
	
	# Start in the swiveled position if configured
	if is_swiveled:
		_set_swiveled_state_instant(true)

func _on_lever_status_changed(lever_name, _is_on) -> void:
	if lever_name == "tree_maze_lever":
		toggle_swivel()
	
# Swivel the branch to the swiveled position
func swivel() -> void:
	# Disable one-way collision during swivel so player can collide normally
	collision_shape_rect.one_way_collision = false
	
	swivel_tween = create_tween()
	swivel_tween.set_parallel(true)
	
	# Calculate the target rotation
	var target_rotation = initial_rotation_degrees + swivel_rotation_degrees
	
	# Calculate the pivot offset to keep the anchor point fixed
	var sprite_size = sprite.get_rect().size * sprite.scale
	var pivot_offset_x = sprite_size.x / 2.0 * anchor_point_offset
	
	# When rotating, we need to adjust position to keep the anchor point fixed
	var anchor_offset = Vector2(pivot_offset_x, 0)
	var rotated_offset = anchor_offset.rotated(deg_to_rad(swivel_rotation_degrees))
	var position_adjustment = anchor_offset - rotated_offset
	
	# Animate rotation of the collision shape (sprite rotates with it as a child)
	swivel_tween.tween_property(collision_shape, "rotation_degrees", target_rotation, swivel_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Animate position to keep anchor point fixed
	swivel_tween.tween_property(collision_shape, "position", initial_position + position_adjustment, swivel_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await swivel_tween.finished
	is_swiveled = true
	is_animating = false
	
	# Re-enable one-way collision after swivel completes
	collision_shape_rect.one_way_collision = true
	
	# collision_shape_rect.disabled = true

# Un-swivel the branch back to initial position
func unswivel() -> void:
	# Disable one-way collision during unswivel so player can collide normally
	collision_shape_rect.one_way_collision = false
	
	swivel_tween = create_tween()
	swivel_tween.set_parallel(true)
	
	# Animate back to initial state
	swivel_tween.tween_property(collision_shape, "rotation_degrees", initial_rotation_degrees, swivel_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	swivel_tween.tween_property(collision_shape, "position", initial_position, swivel_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await swivel_tween.finished
	is_swiveled = false
	is_animating = false
	
	# Re-enable one-way collision after unswivel completes
	collision_shape_rect.one_way_collision = true

# Toggle between swiveled and unswiveled
func toggle_swivel() -> void:
	# Cancel any existing tween
	if swivel_tween:
		swivel_tween.kill()
		
	# Disable collisions while swivel animation is in progress
	# collision_shape_rect.disabled = false
	if is_swiveled:
		unswivel()
	else:
		swivel()

# Set the branch to swiveled state instantly (no animation)
func _set_swiveled_state_instant(swiveled: bool) -> void:
	if swiveled:
		collision_shape.rotation_degrees = initial_rotation_degrees + swivel_rotation_degrees
		
		var sprite_size = sprite.get_rect().size * sprite.scale
		var pivot_offset_x = sprite_size.x / 2.0 * anchor_point_offset
		var anchor_offset = Vector2(pivot_offset_x, 0)
		var rotated_offset = anchor_offset.rotated(deg_to_rad(swivel_rotation_degrees))
		var position_adjustment = anchor_offset - rotated_offset
		
		collision_shape.position = initial_position + position_adjustment
	else:
		collision_shape.rotation_degrees = initial_rotation_degrees
		collision_shape.position = initial_position


func _on_timer_timeout() -> void:
	pass
	# toggle_swivel()

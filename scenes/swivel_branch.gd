extends Node2D

@export var is_facing_right: bool = true

# Branch extends downward with a swivel animation.
# It should appear to stay anchored to the tree trunk when swinging down.
# Technically, this means that when the branch is facing right, the leftmost edge 
# of the sprite, a rectangle, should remain in the same horizontal & vertical position.
# Conversely, when the branch is facing left, the rightmost edge of the sprite should
# remain in the same horizontal & vertical position.
@export var is_facing_down: bool = false

# Degrees to which the branch  will extend
@export var swivel_down_rotation_degrees: float = 80.0

# Configure the speed of the downward swiveling
@export var swivel_down_animation_duration: float = 2.5

@onready var sprite: Sprite2D = find_child('SwivelBranchSprite')

var initial_rotation: float = 0.0
var initial_position: Vector2 = Vector2.ZERO
var is_swiveling: bool = false
var swivel_tween: Tween
var debug_timer: float = 0.0
var debug_toggle_interval: float = 8.0

func _ready() -> void:
	initial_rotation = sprite.rotation_degrees
	initial_position = sprite.position
	sprite.flip_h = !is_facing_right
	
	# Start in the down position if configured
	if is_facing_down:
		_set_swiveled_down_state(true)
	
func _process(delta) -> void:
	sprite.flip_h = !is_facing_right
	
	# Debug: Auto-toggle every 8 seconds
	debug_timer += delta
	if debug_timer >= debug_toggle_interval:
		debug_timer = 0.0
		toggle_swivel()

# Swivel the branch down
func swivel_down() -> void:
	if is_swiveling or is_facing_down:
		return
	
	is_swiveling = true
	is_facing_down = true
	
	# Cancel any existing tween
	if swivel_tween:
		swivel_tween.kill()
	
	swivel_tween = create_tween()
	swivel_tween.set_parallel(true)
	
	# Calculate the target rotation
	var target_rotation = initial_rotation + swivel_down_rotation_degrees
	
	# Calculate the pivot offset to keep the correct edge anchored
	var sprite_size = sprite.get_rect().size * sprite.scale
	var pivot_offset_x = sprite_size.x / 2.0 if is_facing_right else -sprite_size.x / 2.0
	
	# When rotating, we need to adjust position to keep the anchor point fixed
	# The anchor point is at the edge of the sprite
	var anchor_offset = Vector2(pivot_offset_x, 0)
	var rotated_offset = anchor_offset.rotated(deg_to_rad(swivel_down_rotation_degrees))
	var position_adjustment = anchor_offset - rotated_offset
	
	# Animate rotation
	swivel_tween.tween_property(sprite, "rotation_degrees", target_rotation, swivel_down_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Animate position to keep anchor point fixed
	swivel_tween.tween_property(sprite, "position", initial_position + position_adjustment, swivel_down_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await swivel_tween.finished
	is_swiveling = false

# Swivel the branch back up
func swivel_up() -> void:
	if is_swiveling or !is_facing_down:
		return
	
	is_swiveling = true
	is_facing_down = false
	
	# Cancel any existing tween
	if swivel_tween:
		swivel_tween.kill()
	
	swivel_tween = create_tween()
	swivel_tween.set_parallel(true)
	
	# Animate back to initial state
	swivel_tween.tween_property(sprite, "rotation_degrees", initial_rotation, swivel_down_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	swivel_tween.tween_property(sprite, "position", initial_position, swivel_down_animation_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	await swivel_tween.finished
	is_swiveling = false

# Toggle between up and down
func toggle_swivel() -> void:
	if is_facing_down:
		swivel_up()
	else:
		swivel_down()

# Set the branch to the swiveled down state instantly (no animation)
func _set_swiveled_down_state(down: bool) -> void:
	if down:
		sprite.rotation_degrees = initial_rotation + swivel_down_rotation_degrees
		
		var sprite_size = sprite.get_rect().size * sprite.scale
		var pivot_offset_x = sprite_size.x / 2.0 if is_facing_right else -sprite_size.x / 2.0
		var anchor_offset = Vector2(pivot_offset_x, 0)
		var rotated_offset = anchor_offset.rotated(deg_to_rad(swivel_down_rotation_degrees))
		var position_adjustment = anchor_offset - rotated_offset
		
		sprite.position = initial_position + position_adjustment
	else:
		sprite.rotation_degrees = initial_rotation
		sprite.position = initial_position

	

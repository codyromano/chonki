extends CharacterBody2D
# This is a goose enemy character in a 2D side scroller game.
# It jumps periodically with a flying animation.
#
# The jump - both the ascension and descension - should be smooth.
#
# As a point of reference for physics in my game, here are
# the parameters applied to the main character. I want the goose's
# jump to be half as extreme as that of the  player.
#
# const SPEED: float = 2000.0
# const JUMP_FORCE: float = -2500.0
# const GRAVITY: float = 3000.0
#
# Gravity applied to main character
# velocity.y += GRAVITY * delta
#
# Impulse applied to main character
# if Input.is_action_just_pressed("ui_up") and body.is_on_floor():
#	velocity.y = JUMP_FORCE
enum GooseState {
	DEFEATED
}

var states: Dictionary = {}

# Goose physics constants - corrected values
const GOOSE_MAX_JUMP_VELOCITY: float = -1500.0  # Target jump velocity
# const GOOSE_MAX_JUMP_VELOCITY: float = -3000.0  # Target jump velocity
const GOOSE_GRAVITY: float = 3000.0  # Corrected gravity for exactly 1.5 second descent from actual peak
# const TAKEOFF_ACCELERATION: float = -600.0  # Correct acceleration for exactly 2s takeoff
const TAKEOFF_ACCELERATION: float = -3000.0  # Correct acceleration for exactly 2s takeoff
const TAKEOFF_DURATION: float = 2.0  # Safety check for takeoff phase

var is_jumping: bool = false
var jump_phase: String = "none"  # "takeoff", "coasting", "descending", "none"
var takeoff_timer: float = 0.0  # Track takeoff duration
var collisions_disabled: bool = false

const GOOSE_INJURY_TIME: float = 2.5
var goose_last_injured_time: int

@onready var sprite := $AnimatedSprite2D
@onready var hop_timer := $Timer
@onready var collision_shape := $CollisionShape2D


func _ready():
	sprite.play()
	# Set up the timer for 4-second intervals
	hop_timer.wait_time = 4.0
	hop_timer.timeout.connect(_on_hop_timer_timeout)
	hop_timer.start()

func play_audio() -> void:
	if !is_on_floor() && !$FlapAudio.playing:
		$FlapAudio.play()
	
func is_injured() -> bool:
	var current_time = Time.get_unix_time_from_system()
	return (
		goose_last_injured_time != null &&
		current_time - goose_last_injured_time <= GOOSE_INJURY_TIME
	)
		
func get_sprite() -> String:
	sprite.flip_h = false if velocity.x > 0.5 else true
	
	if is_injured():
		return "hurt"
	
	if is_on_floor():
		return "default"
	return "attack"

func temp_disable_collisions() -> void:
	# Store the original collision mask (layers 1 and 2)
	var original_mask = collision_mask
	
	# Set collision mask to only layer 2 (bit 0)
	collision_mask = 2
	
	# Wait 3 seconds, then restore original collision mask
	await get_tree().create_timer(3.0).timeout
	collision_mask = original_mask

func _on_collision_timer_timeout(timer: Timer) -> void:
	collisions_disabled = false
	collision_shape.set_deferred("disabled", false)
	timer.queue_free()  # Clean up the temporary timer
	
func goose_disappear() -> void:
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, 'modulate:a', 0, 1.5)
	await tween.finished
	
	await Utils.spawn_star(self)
	
	var parent = get_parent()
	print("disappear parent: ", parent)
	get_parent().queue_free()
	
func _physics_process(delta: float) -> void:
	# Don't try to move while injured
	if is_injured():
		sprite.play(get_sprite())
		return
		
	# Apply physics first, then check floor status after movement
	if jump_phase == "takeoff":
		# Gradual acceleration over exactly 2 seconds
		velocity.y += TAKEOFF_ACCELERATION * delta
		takeoff_timer += delta
		
		# Switch to coasting when we reach target velocity OR after 2 seconds
		if velocity.y <= GOOSE_MAX_JUMP_VELOCITY or takeoff_timer >= TAKEOFF_DURATION:
			velocity.y = GOOSE_MAX_JUMP_VELOCITY  # Ensure we hit exact target
			jump_phase = "coasting"
	elif jump_phase == "coasting":
		# Coast upward with gravity until we reach peak (velocity = 0)
		velocity.y += GOOSE_GRAVITY * delta
		if velocity.y >= 0:
			jump_phase = "descending"
	elif jump_phase == "descending":
		# Descent with gravity for exactly 1.5 second fall from peak
		velocity.y += GOOSE_GRAVITY * delta
	elif not is_on_floor() and jump_phase == "none":
		# If not jumping but not on floor, apply gravity to fall
		velocity.y += GOOSE_GRAVITY * delta
	
	# Do not modify the sprite logic
	sprite.play(get_sprite())
	
	# Only check for collisions if they're not disabled
	if not collisions_disabled:
		var collision = move_and_collide(velocity * delta)
		if collision:
			var collider: Node2D = collision.get_collider()
			var normal = collision.get_normal()
			
			# Check if collision is from the side (not top/bottom)
			if abs(normal.x) > abs(normal.y):
				print("Side collision detected!")
		
			if "is_attacking" in collider:
				if collider.is_attacking():
					Utils.throttle('goose_hit', func():
						$GooseDefeated.play()
						goose_last_injured_time = Time.get_unix_time_from_system()
						var meter = find_parent('WithHealthMeter')
						meter.total_hearts = max(meter.total_hearts - 1, 0)
						
						if meter.total_hearts == 0:
							states[GooseState.DEFEATED] = true
							goose_disappear()
					, 2)
				elif !states.has(GooseState.DEFEATED): 
					Utils.throttle('player_hit', func():
						GlobalSignals.player_hit.emit()
					, 3)
			else:
				pass
				# print("collided with non-player:  " + collider.name)
	else:
		# Move without collision detection when disabled
		position += velocity * delta
	
	play_audio()
	
	# Reset jump state only after movement if we land during a jump
	if is_on_floor() and is_jumping and jump_phase == "descending":
		is_jumping = false
		jump_phase = "none"
		takeoff_timer = 0.0

# This function is associated with a Timer node, an immediate child.
# It executes every 4 seconds.
func _on_hop_timer_timeout():	
	# Start the gradual takeoff process when on the floor
	if is_on_floor():
		is_jumping = true
		jump_phase = "takeoff"
		takeoff_timer = 0.0
		# Give modest initial upward velocity to get off the ground
		velocity.y = -600.0

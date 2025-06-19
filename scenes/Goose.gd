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

@onready var sprite := $AnimatedSprite2D
@onready var hop_timer := $Timer

func _ready():
	sprite.play()
	# Set up the timer for 4-second intervals
	hop_timer.wait_time = 4.0
	hop_timer.timeout.connect(_on_hop_timer_timeout)
	hop_timer.start()

func play_audio() -> void:
	if !is_on_floor() && !$FlapAudio.playing:
		$FlapAudio.play()
	
# Do not change this. Sprite is okay
func get_sprite() -> String:
	if is_on_floor():
		return "default"
	return "attack"

func _physics_process(delta: float) -> void:
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
	
	# Move first, then check if we landed
	move_and_slide()
	
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


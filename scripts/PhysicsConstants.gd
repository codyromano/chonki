# PhysicsConstants.gd
# Centralized physics-related constants for the entire project.
extends Object
class_name PhysicsConstants

# Movement speeds
const SPEED: float = 4375.0
const MAX_SPEED: float = 8750.0
const SLIDE_THRESHOLD: float = (SPEED + MAX_SPEED) / 2.0
const TIME_UNTIL_MAX_SPEED: float = 1.0  # Reduced from 2.0 to 1.0 second
const ACCEL_TIME: float = 0.15  # Time to reach full speed
const ACCELERATION: float = SPEED / ACCEL_TIME

const DECEL_TIME: float = 0.5   # Time to fully stop when no input (sliding)
const DECELERATION: float = SPEED / DECEL_TIME

const DECEL_TIME_FOR_NON_SLIDING: float = 0.2  # Time to fully stop when not sliding
const DECELERATION_NON_SLIDING: float = SPEED / DECEL_TIME_FOR_NON_SLIDING

# Jump and gravity
const JUMP_FORCE: float = -8000.0
const GRAVITY: float = 20000.0
const MAX_FALL_SPEED: float = 9000.0

# Hit recovery
const HIT_RECOVERY_TIME: float = 1.0

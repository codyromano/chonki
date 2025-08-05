# PhysicsConstants.gd
# Centralized physics-related constants for the entire project.
extends Object
class_name PhysicsConstants

# Movement speeds
const SPEED: float = 3500.0
const ACCEL_TIME: float = 0.15  # Time to reach full speed
const ACCELERATION: float = SPEED / ACCEL_TIME

const DECEL_TIME: float = 0.5   # Time to fully stop when no input (sliding)
const DECELERATION: float = SPEED / DECEL_TIME

# Jump and gravity
const JUMP_FORCE: float = -8000.0
const GRAVITY: float = 20000.0
const MAX_FALL_SPEED: float = 9000.0

# Hit recovery
const HIT_RECOVERY_TIME: float = 1.0

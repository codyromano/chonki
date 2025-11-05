extends ColorRect

@export var jump_multiplier: float = 1.0

func _ready():
	color = Color.YELLOW
	var jump_height = abs(PhysicsConstants.JUMP_FORCE * jump_multiplier / PhysicsConstants.GRAVITY)
	size = Vector2(20, jump_height)

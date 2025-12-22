extends GPUParticles2D

@onready var bonus_chonki: Node2D = null

func _ready() -> void:
	var parent = get_parent()
	if parent:
		bonus_chonki = parent.get_parent()

func _process(_delta: float) -> void:
	if bonus_chonki and "has_jetpack" in bonus_chonki:
		if bonus_chonki.has_jetpack and not emitting:
			emitting = true
		elif not bonus_chonki.has_jetpack and emitting:
			emitting = false

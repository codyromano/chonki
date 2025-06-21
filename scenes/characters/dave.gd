extends Area2D

enum State {
	CONCERNED,
	HAPPIER,
	HAPPY
}

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var state: State = State.CONCERNED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_sprite() -> String:
	match state:
		State.HAPPIER:
			return "happier"
		State.HAPPY:
			return "happy"
	return "default"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.play(get_sprite())
	sprite.flip_h = sprite.animation in ["happier", "happy"]
	
func _on_body_entered(body):
	print(body)
	if body.name == "ChonkiCharacter":
		state = State.HAPPIER

extends Area2D

enum State {
	CONCERNED,
	HAPPY
}

@export var zoom_intensity: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var state: State = State.CONCERNED

func _ready() -> void:
	sprite.play()

func get_sprite() -> String:
	return "happy" if state == State.HAPPY else "concerned"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var next_sprite = get_sprite()
	
	if sprite.animation != next_sprite:
		print("play ", next_sprite)
		sprite.play(next_sprite)
	
func _on_body_entered(body):
	if body.name == "ChonkiCharacter":
		print("Dave collision detected! Zoom intensity: ", zoom_intensity)
		GlobalSignals.win_game.emit(zoom_intensity)
		state = State.HAPPY

extends Area2D

enum State {
	CONCERNED,
	HAPPY
}

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
		
	sprite.flip_h = sprite.animation == "happy"
	
func _on_body_entered(body):
	if body.name == "ChonkiCharacter":
		GlobalSignals.win_game.emit()
		state = State.HAPPY

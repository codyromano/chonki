extends Area2D

var is_standing_at_library: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("read"):
		GlobalSignals.enter_little_free_library.emit()

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		is_standing_at_library = true


func _on_body_exited(body):
	if body.name == 'ChonkiCharacter':
		is_standing_at_library = false

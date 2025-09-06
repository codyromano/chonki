extends Area2D

var is_standing_at_library: bool = false
var has_entered_library: bool = false  # Prevent multiple entries

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$AnimatedSprite2D.play(
		"open" if is_standing_at_library else "default"
	)
	if is_standing_at_library && Input.is_action_just_pressed("read") && !has_entered_library:
		has_entered_library = true
		GlobalSignals.enter_little_free_library.emit()

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		$AudioStreamPlayer.play()
		is_standing_at_library = true


func _on_body_exited(body):
	if body.name == 'ChonkiCharacter':
		is_standing_at_library = false
		# Reset the library entry flag when leaving the area
		has_entered_library = false

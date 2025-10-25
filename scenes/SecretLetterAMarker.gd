extends Marker2D

func _ready() -> void:
	# Connect to the global signal
	GlobalSignals.unlock_ruby_quest_reward.connect(_on_unlock_ruby_quest_reward)

func _on_unlock_ruby_quest_reward() -> void:
	# Load and instantiate the SecretLetter scene
	var secret_letter_scene = preload("res://scenes/SecretLetter.tscn")
	var secret_letter = secret_letter_scene.instantiate()
	
	# Set the letter to "a"
	secret_letter.letter = "a"
	
	# Position it at this marker's location
	secret_letter.global_position = global_position
	
	# Add it to the parent deferred to avoid physics query issues
	if get_parent():
		get_parent().call_deferred("add_child", secret_letter)
	else:
		push_error("SecretLetterAMarker has no parent!")

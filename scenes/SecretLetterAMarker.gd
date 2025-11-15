extends Marker2D

func _ready() -> void:
	# Connect to the global signal
	GlobalSignals.unlock_ruby_quest_reward.connect(_on_unlock_ruby_quest_reward)

func _on_unlock_ruby_quest_reward() -> void:
	print("[SecretLetterAMarker] _on_unlock_ruby_quest_reward called - spawning letter 'a'")
	# Load and instantiate the SecretLetter scene
	var secret_letter_scene = preload("res://scenes/SecretLetter.tscn")
	var secret_letter = secret_letter_scene.instantiate()
	
	# Set the letter to "a"
	secret_letter.letter = "a"
	print("[SecretLetterAMarker] Set letter property to: '", secret_letter.letter, "'")
	
	# Position it at this marker's location
	secret_letter.global_position = global_position
	print("[SecretLetterAMarker] Positioned letter at: ", global_position)
	
	# Add it to the parent deferred to avoid physics query issues
	if get_parent():
		print("[SecretLetterAMarker] Adding letter to parent: ", get_parent().name)
		get_parent().call_deferred("add_child", secret_letter)
	else:
		print("[SecretLetterAMarker] ERROR: No parent found!")

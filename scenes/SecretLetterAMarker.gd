extends Marker2D

func _ready() -> void:
	# Connect to the global signal
	GlobalSignals.unlock_ruby_quest_reward.connect(_on_unlock_ruby_quest_reward)

func _on_unlock_ruby_quest_reward() -> void:
	var secret_letter_scene = preload("res://scenes/SecretLetter.tscn")
	var secret_letter = secret_letter_scene.instantiate()
	
	secret_letter.letter = "a"
	secret_letter.global_position = global_position
	
	if get_parent():
		get_parent().call_deferred("add_child", secret_letter)

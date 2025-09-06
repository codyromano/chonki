extends Button

func _on_pressed() -> void:
	print("Back button pressed - calling SceneStack.pop_scene()")
	SceneStack.pop_scene()

extends Button

func _gui_input(event: InputEvent) -> void:
	# Handle both "read" and "jump" actions to activate the back button
	if has_focus() and (event.is_action_pressed("read") or event.is_action_pressed("jump")):
		print("BackButton handling action - has focus: ", has_focus())
		_on_pressed()
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()  # Prevent other buttons from handling this input

func _on_pressed() -> void:
	print("Back button pressed - calling SceneStack.pop_scene()")
	SceneStack.pop_scene()

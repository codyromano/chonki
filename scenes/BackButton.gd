extends Button

func _ready() -> void:
	# Set up focus navigation to letter buttons when pressing up
	call_deferred("_setup_focus_navigation")

func _setup_focus_navigation() -> void:
	# Find the SelectLettersButtonContainer specifically
	var scene_root = get_tree().current_scene
	
	var letter_container = scene_root.find_child("SelectLettersButtonContainer", true, false)
	
	if letter_container:
		var first_letter_button = null
		
		# Find the first focusable letter button
		for child in letter_container.get_children():
			if child is Button and child.focus_mode != Control.FOCUS_NONE and not child.disabled:
				if not first_letter_button:
					first_letter_button = child
					set("focus_neighbor_up", child.get_path())
		
		# Set up down neighbors for all letter buttons
		if first_letter_button:
			_setup_letter_button_down_neighbors(letter_container)

func _setup_letter_button_down_neighbors(letter_container: Node) -> void:
	# Set this back button as the down neighbor for all letter buttons
	for child in letter_container.get_children():
		if child is Button and child.focus_mode != Control.FOCUS_NONE:
			child.set("focus_neighbor_down", get_path())

func _gui_input(event: InputEvent) -> void:
	# Handle both "ui_accept" and "ui_up" actions to activate the back button
	if has_focus() and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up")):
		_on_pressed()
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()

func _on_pressed() -> void:
	SceneStack.pop_scene()

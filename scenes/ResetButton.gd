extends Button

func _ready() -> void:
	visible = false
	GlobalSignals.on_data_button_selected.connect(
		_on_data_button_selected
	)
	
	GlobalSignals.press_reset_anagram.connect(
		_press_reset_anagram
	)
	
	# Set up focus navigation to letter buttons when pressing up
	call_deferred("_setup_focus_navigation")

func _setup_focus_navigation() -> void:
	# Find the SelectLettersButtonContainer specifically
	var scene_root = get_tree().current_scene
	var letter_container = scene_root.find_child("SelectLettersButtonContainer", true, false)
	
	if letter_container:
		# Find the first focusable letter button
		for child in letter_container.get_children():
			if child is Button and child.focus_mode != Control.FOCUS_NONE and not child.disabled:
				set("focus_neighbor_up", child.get_path())
				print("ResetButton: Setting focus_neighbor_up to: ", child.get_path())
				break

func _gui_input(event: InputEvent) -> void:
	# Handle both "read" and "jump" actions to activate the reset button
	if has_focus() and (event.is_action_pressed("read") or event.is_action_pressed("jump")):
		print("ResetButton handling action - has focus: ", has_focus())
		_on_pressed()
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()  # Prevent other buttons from handling this input
	
func _on_data_button_selected(id: String, data: String) -> void:
	if id == 'letter_button':
		visible = true

func _press_reset_anagram() -> void:
	visible = false

func _on_pressed():
	GlobalSignals.press_reset_anagram.emit()

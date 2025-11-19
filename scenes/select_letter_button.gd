extends Button

@export var id: String
@export var rendering_order: int
@export var data: String

const TOTAL_CHARACTERS: int = 5

func _ready() -> void:
	text = data
	
func _gui_input(event: InputEvent) -> void:
	# Handle both "ui_accept" and "ui_up" actions to select the button
	if has_focus() and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up")):
		print("Button ", data, " handling action - has focus: ", has_focus())
		_on_button_down()
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()  # Prevent other buttons from handling this input
	
func animate_hide_button() -> void:
	focus_mode = Control.FOCUS_NONE

	var tween = create_tween()
	tween.tween_property(self, 'modulate:a', 0, 0.25)
	await tween.finished
	# queue_free.call_deferred()
	
func update_button_focus() -> void:
	# After this button is hidden, we want to call grab_focus on
	# the first sibling button toward the right that is not disabled.
	# If all the buttons toward the right are disabled, check on the
	# left until we find a button that is not disabled. 
	# If all the sibling buttons are disabled, then grab_focus on
	# BackToGameButton. You can find by using find_child on the scene root.
	
	# Get all buttons in the same container
	var container = get_parent()
	if not container:
		return
	
	var all_buttons = container.get_children()
	var current_index = all_buttons.find(self)
	
	if current_index == -1:
		return
	
	# Rebuild the horizontal focus chain for remaining focusable buttons
	_rebuild_horizontal_focus_chain()
	
	# Try to find an enabled button to the right
	for i in range(current_index + 1, all_buttons.size()):
		var button = all_buttons[i]
		if button is Button and button.focus_mode != Control.FOCUS_NONE:
			button.grab_focus()
			return
	
	# If no enabled button to the right, try to the left
	for i in range(current_index - 1, -1, -1):
		var button = all_buttons[i]
		if button is Button and button.focus_mode != Control.FOCUS_NONE:
			button.grab_focus()
			return
	
	# If all sibling buttons are disabled, focus the BackToGameButton
	var scene_root = get_tree().current_scene
	var back_button = scene_root.find_child("BackToGameButton", true, false)
	if back_button:
		back_button.grab_focus()

func _rebuild_horizontal_focus_chain():
	# Get all focusable letter buttons and rebuild their left/right neighbors
	var container = get_parent()
	if not container:
		return
	
	var focusable_buttons = []
	for child in container.get_children():
		if child is Button and child.focus_mode != Control.FOCUS_NONE:
			focusable_buttons.append(child)
	
	# Clear existing horizontal neighbors for all buttons
	for button in focusable_buttons:
		button.focus_neighbor_left = NodePath()
		button.focus_neighbor_right = NodePath()
	
	# Rebuild the chain
	for i in range(focusable_buttons.size()):
		var button = focusable_buttons[i]
		
		# Set left neighbor
		if i > 0:
			button.focus_neighbor_left = focusable_buttons[i - 1].get_path()
		
		# Set right neighbor  
		if i < focusable_buttons.size() - 1:
			button.focus_neighbor_right = focusable_buttons[i + 1].get_path()

func _on_button_down() -> void:
	if !disabled:
		GlobalSignals.on_data_button_selected.emit(id, data)
		disabled = true
		animate_hide_button()
		update_button_focus()
		

extends Button

@export var id: String
@export var rendering_order: int
@export var data: String

const TOTAL_CHARACTERS: int = 5

func _ready() -> void:
	text = data
	
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
	
	# Try to find an enabled button to the right
	for i in range(current_index + 1, all_buttons.size()):
		var button = all_buttons[i]
		if button is Button and not button.disabled:
			button.grab_focus()
			return
	
	# If no enabled button to the right, try to the left
	for i in range(current_index - 1, -1, -1):
		var button = all_buttons[i]
		if button is Button and not button.disabled:
			button.grab_focus()
			return
	
	# If all sibling buttons are disabled, focus the BackToGameButton
	var scene_root = get_tree().current_scene
	var back_button = scene_root.find_child("BackToGameButton", true, false)
	if back_button:
		back_button.grab_focus()

func _on_button_down() -> void:
	if !disabled:
		GlobalSignals.on_data_button_selected.emit(id, data)
		disabled = true
		animate_hide_button()
		update_button_focus()
		

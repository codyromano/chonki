extends GutTest

var dialogue_display_scene = preload("res://scenes/composable/main_dialogue_display.tscn")
var dialogue_display: PanelContainer
var mock_controller_script = preload("res://scenes/MainDialogueController.gd")

func before_each():
	dialogue_display = dialogue_display_scene.instantiate()
	add_child_autofree(dialogue_display)
	
	await wait_frames(1)
	dialogue_display.set_dialogue("Test dialogue text")

func after_each():
	dialogue_display = null

func test_press_enter_label_hidden_initially():
	await wait_frames(1)
	
	var press_enter_label = dialogue_display.get_node("VBoxContainer/VBoxContainer/PressEnterLabel")
	
	dialogue_display.dialogue_options_count = 1
	dialogue_display.is_typewriter_active = true
	dialogue_display._process(0.0)
	assert_false(press_enter_label.visible, "Press Enter label should be hidden when there are dialogue options")
	
	dialogue_display.dialogue_options_count = 0
	dialogue_display.is_typewriter_active = true
	dialogue_display._process(0.0)
	assert_false(press_enter_label.visible, "Press Enter label should stay hidden while typewriter is active")

func test_press_enter_label_visible_after_single_continue():
	dialogue_display.dialogue_options_count = 0
	dialogue_display.is_typewriter_active = false
	
	dialogue_display._process(0.0)
	
	var press_enter_label = dialogue_display.get_node("VBoxContainer/VBoxContainer/PressEnterLabel")
	assert_true(press_enter_label.visible, "Press Enter label should be visible when no options and typewriter done")

func test_buttons_created_for_multiple_choices():
	var choices = [
		{"id": "choice-1", "text": "Option A", "next_node": null},
		{"id": "choice-2", "text": "Option B", "next_node": null}
	]
	
	MainDialogueController.current_dialogue_choices = choices
	
	dialogue_display._on_typewriter_complete()
	
	await wait_frames(2)
	
	var dialogue_options_container = dialogue_display.get_node("VBoxContainer/VBoxContainer/DialogueOptions")
	var button_count = 0
	for child in dialogue_options_container.get_children():
		if child is Button and child.visible:
			button_count += 1
	
	assert_eq(button_count, 2, "Should create 2 buttons for 2 choices")

func test_enter_key_emits_dismiss_for_no_choices():
	await wait_frames(1)
	
	var choices = []
	
	MainDialogueController.current_dialogue_choices = choices
	dialogue_display._on_typewriter_complete()
	dialogue_display.can_dismiss_dialogue = true
	dialogue_display.is_dismissing = false
	dialogue_display.dialogue_options_count = 0
	
	var dialogue_options_container = dialogue_display.get_node("VBoxContainer/VBoxContainer/DialogueOptions")
	dialogue_options_container.visible = false
	
	await wait_frames(1)
	
	watch_signals(GlobalSignals)
	
	var input_event = InputEventAction.new()
	input_event.action = "ui_accept"
	input_event.pressed = true
	
	dialogue_display._unhandled_input(input_event)
	
	assert_signal_emitted(GlobalSignals, "dismiss_active_main_dialogue", "Should emit dismiss for no choices")

func test_first_dialogue_option_is_auto_focused():
	await wait_frames(1)
	
	var choices = [
		{"id": "yes", "text": "Yes, I'll help!", "next_node": null},
		{"id": "no", "text": "No, sorry.", "next_node": null}
	]
	
	MainDialogueController.current_dialogue_choices = choices
	dialogue_display._on_typewriter_complete()
	
	await wait_frames(3)
	
	var dialogue_options_container = dialogue_display.get_node("VBoxContainer/VBoxContainer/DialogueOptions")
	var first_button = null
	for child in dialogue_options_container.get_children():
		if child is Button and child.visible:
			first_button = child
			break
	
	assert_not_null(first_button, "Should have at least one visible button")
	assert_true(dialogue_options_container.visible, "Dialogue options container should be visible")
	assert_eq(dialogue_display.dialogue_options_count, 2, "Should have 2 dialogue options")

func test_dialogue_blocks_ui_up_when_options_visible():
	await wait_frames(1)
	
	var choices = [
		{"id": "yes", "text": "Yes, I'll help!", "next_node": null},
		{"id": "no", "text": "No, sorry.", "next_node": null}
	]
	
	MainDialogueController.current_dialogue_choices = choices
	dialogue_display._on_typewriter_complete()
	
	await wait_frames(2)
	
	var input_event = InputEventAction.new()
	input_event.action = "ui_up"
	input_event.pressed = true
	
	dialogue_display._unhandled_input(input_event)
	
	assert_true(get_viewport().is_input_handled(), "Should consume ui_up input when dialogue options are visible")

func test_dialogue_does_not_block_input_when_no_options():
	await wait_frames(1)
	
	dialogue_display.dialogue_options_count = 0
	dialogue_display.can_dismiss_dialogue = true
	dialogue_display.is_dismissing = false
	
	var dialogue_options_container = dialogue_display.get_node("VBoxContainer/VBoxContainer/DialogueOptions")
	dialogue_options_container.visible = false
	
	watch_signals(GlobalSignals)
	
	var input_event = InputEventAction.new()
	input_event.action = "ui_accept"
	input_event.pressed = true
	
	dialogue_display._unhandled_input(input_event)
	
	assert_signal_emitted(GlobalSignals, "dismiss_active_main_dialogue", "Should dismiss dialogue when no options showing")

func test_dialogue_controller_has_rendered_dialogue_when_active():
	MainDialogueController.rendered_dialogue = dialogue_display
	
	assert_not_null(MainDialogueController.rendered_dialogue, "Should have rendered dialogue when active")
	assert_true(is_instance_valid(MainDialogueController.rendered_dialogue), "Rendered dialogue should be valid")
	
	MainDialogueController.rendered_dialogue = null
	
	assert_null(MainDialogueController.rendered_dialogue, "Should clear rendered dialogue")

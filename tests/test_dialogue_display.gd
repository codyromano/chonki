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

func test_continue_button_not_created_for_single_continue_choice():
	var choices = [
		{"id": "test-continue", "text": "Continue", "next_node": null}
	]
	
	MainDialogueController.current_dialogue_choices = choices
	
	var dialogue_options_container = dialogue_display.get_node("VBoxContainer/VBoxContainer/DialogueOptions")
	for child in dialogue_options_container.get_children():
		if child.name.begins_with("DialogueOption"):
			child.queue_free()
	
	dialogue_display._on_typewriter_complete()
	
	await wait_frames(2)
	
	var button_count = 0
	for child in dialogue_options_container.get_children():
		if child is Button and child.name.begins_with("DialogueOption"):
			button_count += 1
	
	assert_eq(button_count, 0, "Should not create Continue button")
	assert_true(dialogue_display.can_dismiss_dialogue, "Should enable dismiss dialogue")

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

func test_enter_key_emits_dialogue_option_selected_for_continue():
	var choices = [
		{"id": "test-continue-id", "text": "Continue", "next_node": null}
	]
	
	MainDialogueController.current_dialogue_choices = choices
	dialogue_display._on_typewriter_complete()
	dialogue_display.can_dismiss_dialogue = true
	
	watch_signals(GlobalSignals)
	
	var input_event = InputEventAction.new()
	input_event.action = "ui_accept"
	input_event.pressed = true
	
	dialogue_display._unhandled_input(input_event)
	
	assert_signal_emitted(GlobalSignals, "dialogue_option_selected", "Should emit dialogue_option_selected for Continue")
	assert_signal_emit_count(GlobalSignals, "dialogue_option_selected", 1)

func test_enter_key_emits_dismiss_for_no_choices():
	var choices = []
	
	MainDialogueController.current_dialogue_choices = choices
	dialogue_display._on_typewriter_complete()
	dialogue_display.can_dismiss_dialogue = true
	
	watch_signals(GlobalSignals)
	
	var input_event = InputEventAction.new()
	input_event.action = "ui_accept"
	input_event.pressed = true
	
	dialogue_display._unhandled_input(input_event)
	
	assert_signal_emitted(GlobalSignals, "dismiss_active_main_dialogue", "Should emit dismiss for no choices")

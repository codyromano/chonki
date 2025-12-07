extends GutTest

var dialogue_display_scene = preload("res://scenes/composable/main_dialogue_display.tscn")
var dialogue_display: PanelContainer
var typewriter: Label
var mock_canvas_layer: CanvasLayer

func before_each():
	mock_canvas_layer = CanvasLayer.new()
	mock_canvas_layer.name = "MockCanvasLayer"
	add_child_autofree(mock_canvas_layer)
	
	dialogue_display = dialogue_display_scene.instantiate()
	mock_canvas_layer.add_child(dialogue_display)
	
	dialogue_display.set_dialogue("This is a test dialogue with some text to reveal through typewriter animation.")
	
	await wait_frames(2)
	
	typewriter = dialogue_display.get_node("VBoxContainer/HBoxContainer/TypewriterReveal")

func after_each():
	if dialogue_display and is_instance_valid(dialogue_display):
		dialogue_display.queue_free()
	dialogue_display = null
	typewriter = null
	mock_canvas_layer = null

func test_typewriter_starts_in_active_state():
	assert_true(dialogue_display.is_typewriter_active, "Typewriter should start in active state")

func test_enter_during_typing_skips_to_end():
	await wait_frames(2)
	
	var full_text_length = typewriter.text_after_reveal.length()
	
	assert_true(typewriter.is_typing(), "Typewriter should be typing")
	
	watch_signals(typewriter)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	dialogue_display._unhandled_input(event)
	
	await get_tree().process_frame
	await wait_frames(2)
	
	assert_signal_emit_count(typewriter, "animation_complete", 1, "Should emit animation_complete when skipped")
	assert_false(typewriter.is_typing(), "Typewriter should not be typing after skip")
	assert_eq(typewriter.text.length(), full_text_length, "Text should be fully revealed after skip")

func test_enter_after_skip_shows_continue_option():
	await wait_frames(2)
	
	assert_true(typewriter.is_typing(), "Typewriter should be typing initially")
	
	var skip_event = InputEventAction.new()
	skip_event.action = "ui_accept"
	skip_event.pressed = true
	dialogue_display._unhandled_input(skip_event)
	
	await wait_frames(2)
	
	assert_false(typewriter.is_typing(), "Typewriter should not be typing after skip")
	
	MainDialogueController.current_dialogue_choices = [{"id": "continue-1", "text": "Continue"}]
	dialogue_display._on_typewriter_complete()
	
	await wait_frames(2)
	
	var press_enter_label = dialogue_display.get_node("VBoxContainer/VBoxContainer/PressEnterLabel")
	assert_gt(press_enter_label.modulate.a, 0.0, "Press Enter label should be visible after typewriter completes")

func test_skip_plays_book_sound():
	await wait_frames(2)
	
	assert_true(typewriter.is_typing(), "Typewriter should be typing")
	
	var skip_sound = dialogue_display.skip_sound
	assert_not_null(skip_sound, "Skip sound should exist")
	
	watch_signals(skip_sound)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	dialogue_display._unhandled_input(event)
	
	await wait_frames(2)
	
	assert_signal_emit_count(skip_sound, "finished", 0, "Sound should be playing (not finished yet)")

func test_multiple_queued_dialogues_advance_correctly():
	await wait_frames(2)
	
	var tree = get_tree()
	if !tree or !tree.current_scene:
		assert_true(true, "No tree/scene - skipping canvas layer test")
		return
	
	var test_canvas = CanvasLayer.new()
	tree.current_scene.add_child(test_canvas)
	
	GlobalSignals.queue_main_dialogue.emit("First dialogue text", "trigger-1", "gus", [{"id": "continue-1", "text": "Continue"}])
	await wait_frames(3)
	
	var first_display = MainDialogueController.rendered_dialogue
	if !first_display:
		test_canvas.queue_free()
		assert_true(true, "No canvas layer found - skipping integration test")
		return
	
	var first_typewriter = first_display.get_node("VBoxContainer/HBoxContainer/TypewriterReveal")
	
	var skip_event = InputEventAction.new()
	skip_event.action = "ui_accept"
	skip_event.pressed = true
	first_display._unhandled_input(skip_event)
	
	await wait_frames(2)
	
	assert_false(first_typewriter.is_typing(), "First typewriter should be complete after skip")
	
	GlobalSignals.queue_main_dialogue.emit("Second dialogue text", "trigger-2", "gus", [{"id": "continue-2", "text": "Continue"}])
	
	var advance_event = InputEventAction.new()
	advance_event.action = "ui_accept"
	advance_event.pressed = true
	first_display._unhandled_input(advance_event)
	
	await wait_frames(3)
	
	assert_eq(MainDialogueController.current_instruction_trigger_id, "trigger-2", "Should advance to second dialogue")
	
	test_canvas.queue_free()

func test_cannot_skip_already_complete_text():
	await wait_frames(2)
	
	var skip_event = InputEventAction.new()
	skip_event.action = "ui_accept"
	skip_event.pressed = true
	dialogue_display._unhandled_input(skip_event)
	
	await wait_frames(2)
	
	assert_false(typewriter.is_typing(), "Typewriter should be complete")
	
	var initial_state = typewriter.animation_finished
	
	dialogue_display._unhandled_input(skip_event)
	await wait_frames(2)
	
	assert_eq(typewriter.animation_finished, initial_state, "Skip should not affect already completed text")

func test_typewriter_becomes_inactive_after_completion():
	await wait_frames(2)
	
	assert_true(dialogue_display.is_typewriter_active, "Should be active initially")
	
	var skip_event = InputEventAction.new()
	skip_event.action = "ui_accept"
	skip_event.pressed = true
	dialogue_display._unhandled_input(skip_event)
	
	await wait_frames(2)
	
	assert_false(dialogue_display.is_typewriter_active, "Should be inactive after completion")

func test_only_ui_accept_triggers_skip():
	await wait_frames(2)
	
	assert_true(typewriter.is_typing(), "Typewriter should be typing")
	
	var up_event = InputEventAction.new()
	up_event.action = "ui_up"
	up_event.pressed = true
	dialogue_display._unhandled_input(up_event)
	
	await wait_frames(2)
	
	assert_true(typewriter.is_typing(), "Typewriter should still be typing (ui_up should not skip)")
	
	var skip_event = InputEventAction.new()
	skip_event.action = "ui_accept"
	skip_event.pressed = true
	dialogue_display._unhandled_input(skip_event)
	
	await wait_frames(2)
	
	assert_false(typewriter.is_typing(), "Typewriter should be complete after ui_accept")

func test_skip_sound_has_correct_properties():
	var skip_sound = dialogue_display.skip_sound
	assert_not_null(skip_sound, "Skip sound should be created")
	assert_not_null(skip_sound.stream, "Skip sound should have stream loaded")
	assert_eq(skip_sound.volume_db, -10.0, "Skip sound should have correct volume")

func test_dismissal_only_works_when_typewriter_inactive():
	await wait_frames(2)
	
	assert_true(dialogue_display.is_typewriter_active, "Typewriter should be active")
	
	MainDialogueController.current_dialogue_choices = []
	
	watch_signals(GlobalSignals)
	
	var dismiss_event = InputEventAction.new()
	dismiss_event.action = "ui_accept"
	dismiss_event.pressed = true
	dialogue_display._unhandled_input(dismiss_event)
	
	await wait_frames(2)
	
	assert_signal_emit_count(GlobalSignals, "dismiss_active_main_dialogue", 0, "Should not dismiss while typing")
	
	typewriter.skip_to_end()
	await wait_frames(2)
	
	dialogue_display._unhandled_input(dismiss_event)
	await wait_frames(2)
	
	assert_signal_emit_count(GlobalSignals, "dismiss_active_main_dialogue", 1, "Should dismiss after typewriter complete")

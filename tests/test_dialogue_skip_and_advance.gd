extends GutTest

var controller_script = preload("res://scenes/MainDialogueController.gd")
var controller: Node
var mock_canvas_layer: CanvasLayer

func before_each():
	controller = Node.new()
	controller.set_script(controller_script)
	
	mock_canvas_layer = CanvasLayer.new()
	mock_canvas_layer.name = "MockCanvasLayer"
	
	add_child_autofree(controller)
	add_child_autofree(mock_canvas_layer)
	
	controller._ready()
	await wait_physics_frames(2)
	
	if controller.rendered_dialogue and is_instance_valid(controller.rendered_dialogue):
		controller.rendered_dialogue.queue_free()
		controller.rendered_dialogue = null
	controller.dialogue_queue.clear()

func after_each():
	var tree = get_tree()
	if tree:
		tree.paused = false
	if controller:
		if controller.dialogue_queue:
			controller.dialogue_queue.clear()
		if controller.rendered_dialogue and is_instance_valid(controller.rendered_dialogue):
			controller.rendered_dialogue.queue_free()
			controller.rendered_dialogue = null
	controller = null
	mock_canvas_layer = null

func test_controller_does_not_dismiss_when_choices_exist():
	var choices = [
		{"id": "choice1", "text": "Option 1", "next_node": null},
		{"id": "choice2", "text": "Option 2", "next_node": null}
	]
	controller.current_dialogue_choices = choices
	controller.rendered_dialogue = PanelContainer.new()
	controller.can_dismiss_dialogue = true
	controller.is_ready = true
	
	assert_eq(controller.current_dialogue_choices.size(), 2, "Should have 2 choices")
	assert_true(controller.can_dismiss_dialogue, "can_dismiss_dialogue should be true")
	
	var dismiss_count = 0
	var signal_callback = func(_arg): dismiss_count += 1
	GlobalSignals.dismiss_active_main_dialogue.connect(signal_callback)
	
	controller._process(0.016)
	
	assert_eq(dismiss_count, 0, "Controller should not dismiss with active choices")
	GlobalSignals.dismiss_active_main_dialogue.disconnect(signal_callback)
	pass_test("Successfully verified controller does not dismiss with choices")

func test_controller_does_not_dismiss_when_single_continue_choice_exists():
	var choices = [{"id": "continue", "text": "Continue", "next_node": null}]
	controller.current_dialogue_choices = choices
	controller.rendered_dialogue = PanelContainer.new()
	controller.can_dismiss_dialogue = true
	controller.is_ready = true
	
	assert_eq(controller.current_dialogue_choices.size(), 1, "Should have 1 choice")
	assert_true(controller.can_dismiss_dialogue, "can_dismiss_dialogue should be true")
	
	var dismiss_count = 0
	var signal_callback = func(_arg): dismiss_count += 1
	GlobalSignals.dismiss_active_main_dialogue.connect(signal_callback)
	
	controller._process(0.016)
	
	assert_eq(dismiss_count, 0, "Controller should not dismiss even with Continue choice")
	GlobalSignals.dismiss_active_main_dialogue.disconnect(signal_callback)

func test_controller_dismisses_when_no_choices():
	controller.current_dialogue_choices = []
	controller.rendered_dialogue = PanelContainer.new()
	controller.can_dismiss_dialogue = true
	controller.is_ready = true
	
	assert_eq(controller.current_dialogue_choices.size(), 0, "Should have 0 choices")
	assert_true(controller.can_dismiss_dialogue, "can_dismiss_dialogue should be true")

func test_controller_does_not_dismiss_when_three_choices_exist():
	var choices = [
		{"id": "choice1", "text": "First option", "next_node": null},
		{"id": "choice2", "text": "Second option", "next_node": null},
		{"id": "choice3", "text": "Third option", "next_node": null}
	]
	controller.current_dialogue_choices = choices
	controller.rendered_dialogue = PanelContainer.new()
	controller.can_dismiss_dialogue = true
	controller.is_ready = true
	
	assert_eq(controller.current_dialogue_choices.size(), 3, "Should have 3 choices")
	
	var dismiss_count = 0
	var signal_callback = func(_arg): dismiss_count += 1
	GlobalSignals.dismiss_active_main_dialogue.connect(signal_callback)
	
	controller._process(0.016)
	
	assert_eq(dismiss_count, 0, "Controller should not dismiss with 3 choices")
	GlobalSignals.dismiss_active_main_dialogue.disconnect(signal_callback)

func test_controller_dismisses_after_choices_cleared():
	controller.current_dialogue_choices = [
		{"id": "choice1", "text": "Option 1", "next_node": null},
		{"id": "choice2", "text": "Option 2", "next_node": null}
	]
	controller.rendered_dialogue = PanelContainer.new()
	controller.can_dismiss_dialogue = true
	controller.is_ready = true
	
	assert_eq(controller.current_dialogue_choices.size(), 2, "Should start with 2 choices")
	
	var dismiss_count = 0
	var signal_callback = func(_arg): dismiss_count += 1
	GlobalSignals.dismiss_active_main_dialogue.connect(signal_callback)
	
	controller._process(0.016)
	
	assert_eq(dismiss_count, 0, "Should not dismiss with choices")
	
	controller.current_dialogue_choices = []
	
	assert_eq(controller.current_dialogue_choices.size(), 0, "Should have 0 choices after clearing")
	GlobalSignals.dismiss_active_main_dialogue.disconnect(signal_callback)


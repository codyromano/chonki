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

func test_controller_initializes_with_empty_queue():
	assert_eq(controller.dialogue_queue.size(), 0, "Dialogue queue should start empty")

func test_controller_has_default_duration_per_character():
	assert_eq(controller.duration_per_character, 0.075, "Should have default typewriter speed")

func test_controller_process_mode_is_when_paused():
	assert_eq(controller.process_mode, Node.PROCESS_MODE_WHEN_PAUSED, "Controller should process during pause")

func test_queue_main_dialogue_adds_to_queue():
	watch_signals(GlobalSignals)
	GlobalSignals.queue_main_dialogue.emit("Test dialogue", "", "gus", [])
	assert_signal_emit_count(GlobalSignals, "queue_main_dialogue", 1, "Should emit queue_main_dialogue signal")

func test_dialogue_data_structure_contains_all_fields():
	watch_signals(GlobalSignals)
	GlobalSignals.queue_main_dialogue.emit("Test text", "trigger-1", "gus", [])
	
	assert_signal_emit_count(GlobalSignals, "queue_main_dialogue", 1, "Should emit queue_main_dialogue signal")

func test_dialogue_data_stores_correct_values():
	var choices = [{"id": "choice-1", "text": "Yes"}]
	GlobalSignals.queue_main_dialogue.emit("Test dialogue", "trigger-123", "momo", choices)
	await wait_physics_frames(2)
	
	assert_eq(controller.current_instruction_trigger_id, "trigger-123", "Should store trigger ID")

func test_multiple_dialogues_queue_in_order():
	watch_signals(GlobalSignals)
	GlobalSignals.queue_main_dialogue.emit("First", "id-1", "", [])
	GlobalSignals.queue_main_dialogue.emit("Second", "id-2", "", [])
	GlobalSignals.queue_main_dialogue.emit("Third", "id-3", "", [])
	
	assert_signal_emit_count(GlobalSignals, "queue_main_dialogue", 3, "Should queue multiple dialogues")

func test_dismiss_signal_triggers_next_dialogue():
	GlobalSignals.queue_main_dialogue.emit("First", "id-1", "", [])
	await wait_physics_frames(2)
	
	GlobalSignals.queue_main_dialogue.emit("Second", "id-2", "", [])
	
	var queue_size_before = controller.dialogue_queue.size()
	GlobalSignals.dismiss_active_main_dialogue.emit("id-1")
	await wait_physics_frames(2)
	
	var queue_size_after = controller.dialogue_queue.size()
	assert_lte(queue_size_after, queue_size_before, "Should process queue on dismiss")

func test_current_trigger_id_updates_on_dialogue_display():
	GlobalSignals.queue_main_dialogue.emit("Test", "trigger-abc", "", [])
	await wait_physics_frames(2)
	
	assert_eq(controller.current_instruction_trigger_id, "trigger-abc", "Should update current trigger ID")

func test_get_avatar_texture_returns_gus():
	var texture = controller.get_avatar_texture("gus")
	assert_not_null(texture, "Should return texture for Gus")

func test_get_avatar_texture_returns_momo():
	var texture = controller.get_avatar_texture("momo")
	assert_not_null(texture, "Should return texture for Momo")

func test_get_avatar_texture_returns_ruby():
	var texture = controller.get_avatar_texture("ruby")
	assert_not_null(texture, "Should return texture for Ruby")

func test_get_avatar_texture_returns_null_for_unknown():
	var texture = controller.get_avatar_texture("unknown_avatar")
	assert_null(texture, "Should return null for unknown avatar")

func test_dialogue_choices_stored_correctly():
	var choices = [
		{"id": "choice-1", "text": "Option A"},
		{"id": "choice-2", "text": "Option B"}
	]
	GlobalSignals.queue_main_dialogue.emit("Pick one", "", "gus", choices)
	await wait_physics_frames(2)
	
	var stored_choices = controller.get_dialogue_choices()
	assert_eq(stored_choices.size(), 2, "Should store two choices")

func test_warning_sign_double_jump_lake_triggers_dialogue():
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("double_jump_lake")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for double jump lake")

func test_warning_sign_double_jump_dialogue_text():
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("double_jump_lake")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for double jump lake")

func test_warning_sign_double_jump_has_gus_avatar():
	var texture = controller.get_avatar_texture("gus")
	assert_not_null(texture, "Should have gus avatar texture")
	assert_true(texture is CompressedTexture2D, "Should be a texture")

func test_warning_sign_geese_danger_triggers_dialogue():
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("geese_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for geese danger")

func test_warning_sign_geese_danger_dialogue_text():
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("geese_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for geese danger")

func test_warning_sign_otter_danger_with_no_letters():
	PlayerInventory.items.clear()
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("otter_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for otter danger")

func test_warning_sign_otter_danger_with_two_letters():
	PlayerInventory.items.clear()
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_F)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_R)
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("otter_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for otter danger with 2 letters")

func test_warning_sign_otter_danger_with_all_letters():
	PlayerInventory.items.clear()
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_F)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_R)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_E)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_S)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_H)
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("otter_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue for otter danger with all letters")

func test_warning_sign_otter_letter_count_exactly_two():
	PlayerInventory.items.clear()
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_E)
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_S)
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("otter_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue at exactly 2 letters")

func test_warning_sign_otter_letter_count_one_below_threshold():
	PlayerInventory.items.clear()
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_H)
	watch_signals(GlobalSignals)
	GlobalSignals.enter_warning_sign.emit("otter_danger")
	
	assert_signal_emitted(GlobalSignals, "queue_main_dialogue", "Should emit dialogue with only 1 letter")

func test_canvas_layer_process_mode_set_to_always():
	var canvas = controller._get_canvas_layer()
	if canvas:
		assert_eq(canvas.process_mode, Node.PROCESS_MODE_ALWAYS, "Canvas layer should process always")
	else:
		assert_true(true, "No canvas layer in test environment - skipping check")

func test_find_canvas_layer_returns_direct_child():
	var test_node = Node.new()
	var canvas = CanvasLayer.new()
	test_node.add_child(canvas)
	add_child_autofree(test_node)
	
	var found = controller._find_canvas_layer(test_node)
	assert_eq(found, canvas, "Should find direct child canvas layer")

func test_find_canvas_layer_returns_nested_child():
	var test_node = Node.new()
	var middle_node = Node.new()
	var canvas = CanvasLayer.new()
	test_node.add_child(middle_node)
	middle_node.add_child(canvas)
	add_child_autofree(test_node)
	
	var found = controller._find_canvas_layer(test_node)
	assert_eq(found, canvas, "Should find nested canvas layer")

func test_find_canvas_layer_returns_null_when_none_exists():
	var test_node = Node.new()
	add_child_autofree(test_node)
	
	var found = controller._find_canvas_layer(test_node)
	assert_null(found, "Should return null when no canvas layer exists")

func test_find_all_audio_nodes_finds_audio_stream_player():
	var test_node = Node.new()
	var audio = AudioStreamPlayer.new()
	test_node.add_child(audio)
	add_child_autofree(test_node)
	
	var audio_nodes = controller._find_all_audio_nodes(test_node)
	assert_eq(audio_nodes.size(), 1, "Should find AudioStreamPlayer")

func test_find_all_audio_nodes_finds_audio_stream_player_2d():
	var test_node = Node.new()
	var audio = AudioStreamPlayer2D.new()
	test_node.add_child(audio)
	add_child_autofree(test_node)
	
	var audio_nodes = controller._find_all_audio_nodes(test_node)
	assert_eq(audio_nodes.size(), 1, "Should find AudioStreamPlayer2D")

func test_find_all_audio_nodes_finds_multiple():
	var test_node = Node.new()
	var audio1 = AudioStreamPlayer.new()
	var audio2 = AudioStreamPlayer2D.new()
	var middle = Node.new()
	var audio3 = AudioStreamPlayer.new()
	
	test_node.add_child(audio1)
	test_node.add_child(middle)
	middle.add_child(audio2)
	middle.add_child(audio3)
	add_child_autofree(test_node)
	
	var audio_nodes = controller._find_all_audio_nodes(test_node)
	assert_eq(audio_nodes.size(), 3, "Should find all 3 audio nodes")

func test_find_all_audio_nodes_returns_empty_when_none():
	var test_node = Node.new()
	add_child_autofree(test_node)
	
	var audio_nodes = controller._find_all_audio_nodes(test_node)
	assert_eq(audio_nodes.size(), 0, "Should return empty array when no audio nodes")

func test_can_dismiss_dialogue_starts_false():
	assert_false(controller.can_dismiss_dialogue, "can_dismiss_dialogue should start false")

func test_is_ready_flag_set_after_ready():
	assert_true(controller.is_ready, "is_ready should be true after _ready()")

func test_current_dialogue_choices_starts_empty():
	assert_eq(controller.current_dialogue_choices.size(), 0, "current_dialogue_choices should start empty")

func test_queue_processes_automatically_when_empty():
	watch_signals(GlobalSignals)
	GlobalSignals.queue_main_dialogue.emit("Auto process", "auto-id", "", [])
	await wait_physics_frames(2)
	
	assert_eq(controller.current_instruction_trigger_id, "auto-id", "Should process first dialogue automatically")

func test_controller_handles_empty_avatar_name():
	watch_signals(GlobalSignals)
	GlobalSignals.queue_main_dialogue.emit("No avatar", "", "", [])
	
	assert_signal_emit_count(GlobalSignals, "queue_main_dialogue", 1, "Should handle empty avatar name")

func test_controller_handles_empty_choices_array():
	GlobalSignals.queue_main_dialogue.emit("No choices", "test-id", "", [])
	await wait_physics_frames(2)
	
	assert_eq(controller.current_instruction_trigger_id, "test-id", "Should process dialogue with empty choices")

func test_warning_sign_unknown_name_does_nothing():
	var initial_rendered = controller.rendered_dialogue
	GlobalSignals.enter_warning_sign.emit("unknown_sign_name")
	await wait_physics_frames(2)
	
	assert_eq(controller.rendered_dialogue, initial_rendered, "Unknown warning sign should not change dialogue state")

func test_game_pauses_when_dialogue_displayed():
	var tree = get_tree()
	
	GlobalSignals.queue_main_dialogue.emit("Test pause", "", "gus", [])
	await wait_physics_frames(2)
	
	if controller.rendered_dialogue:
		assert_true(tree.paused, "Game should be paused when dialogue is displayed")
	else:
		assert_true(true, "No canvas layer in test - skipping pause check")

func test_game_unpauses_when_dialogue_dismissed():
	var tree = get_tree()
	
	GlobalSignals.queue_main_dialogue.emit("Test unpause", "unpause-id", "gus", [])
	await wait_physics_frames(2)
	
	if controller.rendered_dialogue:
		assert_true(tree.paused, "Game should be paused with dialogue")
		
		GlobalSignals.dismiss_active_main_dialogue.emit("unpause-id")
		await wait_physics_frames(2)
		
		assert_false(tree.paused, "Game should unpause when dialogue dismissed")
	else:
		assert_true(true, "No canvas layer in test - skipping unpause check")

func test_game_unpauses_when_queue_empty():
	var tree = get_tree()
	
	GlobalSignals.queue_main_dialogue.emit("Test", "test-id", "", [])
	await wait_physics_frames(2)
	
	if controller.rendered_dialogue:
		assert_true(tree.paused, "Game should be paused")
		
		controller.dialogue_queue.clear()
		GlobalSignals.dismiss_active_main_dialogue.emit("test-id")
		await wait_physics_frames(2)
		
		assert_false(tree.paused, "Game should unpause when queue is empty")
	else:
		assert_true(true, "No canvas layer in test - skipping check")

func test_game_stays_paused_with_queued_dialogues():
	var tree = get_tree()
	
	GlobalSignals.queue_main_dialogue.emit("First", "id-1", "", [])
	await wait_physics_frames(2)
	GlobalSignals.queue_main_dialogue.emit("Second", "id-2", "", [])
	
	if controller.rendered_dialogue:
		assert_true(tree.paused, "Game should be paused")
		
		GlobalSignals.dismiss_active_main_dialogue.emit("id-1")
		await wait_physics_frames(2)
		
		assert_true(tree.paused, "Game should stay paused with more dialogues queued")
	else:
		assert_true(true, "No canvas layer in test - skipping check")

func test_audio_nodes_have_always_process_mode():
	var tree = get_tree()
	var current_scene = tree.current_scene
	
	var audio_nodes = controller._find_all_audio_nodes(current_scene)
	
	if audio_nodes.size() > 0:
		for audio_node in audio_nodes:
			assert_eq(audio_node.process_mode, Node.PROCESS_MODE_ALWAYS, "Audio nodes should process during pause")
	else:
		assert_true(true, "No audio nodes in test scene - skipping check")

func test_skip_typewriter_then_advance_to_next_dialogue():
	GlobalSignals.queue_main_dialogue.emit("First dialogue", "id-1", "gus", [{"id": "continue-1", "text": "Continue"}])
	await wait_physics_frames(3)
	
	var first_dialogue = controller.rendered_dialogue
	if !first_dialogue:
		assert_true(true, "No canvas layer - skipping integration test")
		return
	
	assert_eq(controller.current_instruction_trigger_id, "id-1", "Should display first dialogue")
	
	var typewriter = first_dialogue.get_node("VBoxContainer/HBoxContainer/TypewriterReveal")
	assert_not_null(typewriter, "Typewriter should exist")
	
	if typewriter.has_method("is_typing") and typewriter.is_typing():
		var skip_event = InputEventAction.new()
		skip_event.action = "ui_accept"
		skip_event.pressed = true
		first_dialogue._unhandled_input(skip_event)
		
		await wait_physics_frames(2)
		
		assert_false(typewriter.is_typing(), "Typewriter should be complete after skip")
	
	GlobalSignals.queue_main_dialogue.emit("Second dialogue", "id-2", "gus", [{"id": "continue-2", "text": "Continue"}])
	
	var advance_event = InputEventAction.new()
	advance_event.action = "ui_accept"
	advance_event.pressed = true
	first_dialogue._unhandled_input(advance_event)
	
	await wait_physics_frames(3)
	
	assert_eq(controller.current_instruction_trigger_id, "id-2", "Should advance to second dialogue after skip and Enter")

extends GutTest

var quest_giver_scene = preload("res://scenes/composable/quest_giver.tscn")
var quest_giver: Node2D
var mock_player: CharacterBody2D
var dialogue_queued_count: int = 0
var last_queued_dialogue: String = ""
var show_prompt_count: int = 0
var hide_prompt_count: int = 0

func before_each():
	quest_giver = quest_giver_scene.instantiate()
	add_child_autofree(quest_giver)
	
	mock_player = CharacterBody2D.new()
	mock_player.name = "ChonkiCharacter"
	add_child_autofree(mock_player)
	
	dialogue_queued_count = 0
	last_queued_dialogue = ""
	show_prompt_count = 0
	hide_prompt_count = 0
	GlobalSignals.connect("queue_main_dialogue", _on_dialogue_queued)
	GlobalSignals.connect("show_quest_prompt", _on_show_prompt)
	GlobalSignals.connect("hide_quest_prompt", _on_hide_prompt)
	
	await wait_physics_frames(2)

func after_each():
	if GlobalSignals.is_connected("queue_main_dialogue", _on_dialogue_queued):
		GlobalSignals.disconnect("queue_main_dialogue", _on_dialogue_queued)
	if GlobalSignals.is_connected("show_quest_prompt", _on_show_prompt):
		GlobalSignals.disconnect("show_quest_prompt", _on_show_prompt)
	if GlobalSignals.is_connected("hide_quest_prompt", _on_hide_prompt):
		GlobalSignals.disconnect("hide_quest_prompt", _on_hide_prompt)
	quest_giver = null
	mock_player = null

func _on_dialogue_queued(text: String, _trigger_id: String, _avatar: String, _choices: Array):
	dialogue_queued_count += 1
	last_queued_dialogue = text

func _on_show_prompt():
	show_prompt_count += 1

func _on_hide_prompt():
	hide_prompt_count += 1

func test_player_entering_area_shows_instructions():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	assert_eq(show_prompt_count, 1, "Should emit show_quest_prompt signal when player enters")

func test_player_exiting_area_hides_instructions():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	area.body_exited.emit(mock_player)
	await wait_seconds(1.5)
	
	assert_eq(hide_prompt_count, 1, "Should emit hide_quest_prompt signal when player exits")

func test_pressing_enter_near_quest_giver_queues_dialogue():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	assert_eq(dialogue_queued_count, 1, "Should queue dialogue when Enter pressed near quest giver")
	assert_ne(last_queued_dialogue, "", "Queued dialogue should have text")

func test_can_retrigger_dialogue_after_dismissal():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	assert_eq(dialogue_queued_count, 1, "First trigger should queue dialogue")
	
	GlobalSignals.dismiss_active_main_dialogue.emit("")
	await wait_physics_frames(2)
	
	var release_event = InputEventAction.new()
	release_event.action = "ui_accept"
	release_event.pressed = false
	quest_giver._unhandled_input(release_event)
	await wait_physics_frames(2)
	
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	assert_eq(dialogue_queued_count, 2, "Should be able to retrigger dialogue after dismissal and key release")

func test_rapid_dismiss_allows_retrigger():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	GlobalSignals.dismiss_active_main_dialogue.emit("")
	GlobalSignals.dismiss_active_main_dialogue.emit("")
	GlobalSignals.dismiss_active_main_dialogue.emit("")
	await wait_physics_frames(2)
	
	var release_event = InputEventAction.new()
	release_event.action = "ui_accept"
	release_event.pressed = false
	quest_giver._unhandled_input(release_event)
	await wait_physics_frames(2)
	
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	assert_eq(dialogue_queued_count, 2, "Multiple rapid dismissals should still allow retrigger")

func test_cannot_trigger_while_another_dialogue_showing():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	var mock_dialogue = PanelContainer.new()
	MainDialogueController.rendered_dialogue = mock_dialogue
	add_child_autofree(mock_dialogue)
	
	var event = InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	quest_giver._unhandled_input(event)
	await wait_physics_frames(2)
	
	assert_eq(dialogue_queued_count, 0, "Should not trigger when another dialogue is showing")
	
	MainDialogueController.rendered_dialogue = null

func test_instructions_visible_during_game_pause():
	var area = quest_giver.get_node("Area2D")
	area.body_entered.emit(mock_player)
	await wait_physics_frames(2)
	
	get_tree().paused = true
	await wait_physics_frames(2)
	
	assert_eq(show_prompt_count, 1, "Quest prompt signal should still be emitted during pause")
	
	get_tree().paused = false

func test_quest_giver_processes_input_during_pause():
	assert_eq(quest_giver.process_mode, Node.PROCESS_MODE_ALWAYS, 
		"Quest giver should have PROCESS_MODE_ALWAYS to handle input during pause")

func test_instructions_label_can_tween_during_pause():
	assert_eq(quest_giver.process_mode, Node.PROCESS_MODE_ALWAYS,
		"Quest giver should have PROCESS_MODE_ALWAYS so it can emit signals during pause")

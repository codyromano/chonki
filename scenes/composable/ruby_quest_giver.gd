extends "res://scenes/quest_giver.gd"

func _get_quest_state(key: String) -> bool:
	var level = GameState.current_level
	if GameState.quest_states_by_level.has(level) and GameState.quest_states_by_level[level].has(key):
		return GameState.quest_states_by_level[level][key]
	return false

func _set_quest_state(key: String, value: bool) -> void:
	var level = GameState.current_level
	if GameState.quest_states_by_level.has(level):
		GameState.quest_states_by_level[level][key] = value

func _get_dialogue_tree() -> DialogueTree:
	var volleyball_returned = _get_quest_state("ruby_volleyball_returned")
	var reward_given = _get_quest_state("ruby_reward_given")
	var ruby_repeat = DialogueNode.new()
	ruby_repeat.text = "Thanks again, Gus! Hope you enjoy the secret letter."
	ruby_repeat.choices = []
	
	# Dialogue 2 - When Gus returns the ball (completion dialogue) - Part 3
	var ruby_thanks_part3 = DialogueNode.new()
	ruby_thanks_part3.text = "How can I ever thank you, Gus? OH! Here! Take this."
	ruby_thanks_part3.choices = []
	
	# Dialogue 2 - When Gus returns the ball (completion dialogue) - Part 2
	var ruby_thanks_part2 = DialogueNode.new()
	ruby_thanks_part2.text = "You know, I think I forgot how to talk to people. My first full sentence this week was to a vending machine."
	ruby_thanks_part2.choices = [
		{"id": "ruby-thanks-continue-2", "text": "Continue", "next_node": ruby_thanks_part3}
	]
	
	# Dialogue 2 - When Gus returns the ball (completion dialogue) - Part 1
	var ruby_thanks_part1 = DialogueNode.new()
	ruby_thanks_part1.text = "Whoa, you found it! You are officially promoted to Captain Corgi of the Sky-Serve Squad."
	ruby_thanks_part1.choices = [
		{"id": "ruby-thanks-continue-1", "text": "Continue", "next_node": ruby_thanks_part2}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 4
	var ruby_intro_part4 = DialogueNode.new()
	ruby_intro_part4.text = "It's weird—I used to hate crowds. Now I miss strangers. Anyway! Ball first, therapy later."
	ruby_intro_part4.choices = []
	
	# Dialogue 1 - First encounter (quest offer) - Part 3
	var ruby_intro_part3 = DialogueNode.new()
	ruby_intro_part3.text = "I've been coming here every weekend since… well, since the city started breathing again."
	ruby_intro_part3.choices = [
		{"id": "ruby-continue-3", "text": "Continue", "next_node": ruby_intro_part4}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 2
	var ruby_intro_part2 = DialogueNode.new()
	ruby_intro_part2.text = "So, um… my volleyball's gone rogue. If you sniff it out, I'll owe you a lifetime supply of pets."
	ruby_intro_part2.choices = [
		{"id": "ruby-continue-2", "text": "Continue", "next_node": ruby_intro_part3}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 1
	var ruby_intro_part1 = DialogueNode.new()
	ruby_intro_part1.text = "Wait—hold on! You're not a flying corgi, are you? No wings? Okay, that's fine, we'll improvise."
	ruby_intro_part1.choices = [
		{"id": "ruby-continue-1", "text": "Continue", "next_node": ruby_intro_part2}
	]

	var ruby_tree = DialogueTree.new()
	# Choose root based on quest state
	if reward_given:
		ruby_tree.root_node = ruby_repeat
	elif volleyball_returned:
		ruby_tree.root_node = ruby_thanks_part1
	else:
		ruby_tree.root_node = ruby_intro_part1
	return ruby_tree
	
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	return get_next_dialogue_node(current_node, selected_option_id)

func _on_body_entered_override(body: Node2D) -> void:
	# Check if the body is the volleyball
	if body.name == "Volleyball":
		# Mark that volleyball has been returned
		_set_quest_state("ruby_volleyball_returned", true)
		# Reset dialogue to show the thank you dialogue
		current_dialogue_node = null
		
		# Create a tween to fade out the volleyball
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", 0.0, 1.0)
		await tween.finished
		# Queue free deferred after fade completes
		body.queue_free()
		
		sprite.play('happy')

func on_dialogue_finished() -> void:
	# Only emit signal if volleyball has been returned and reward not yet given
	var volleyball_returned = _get_quest_state("ruby_volleyball_returned")
	var reward_given = _get_quest_state("ruby_reward_given")
	if volleyball_returned and not reward_given:
		_set_quest_state("ruby_reward_given", true)
		GlobalSignals.unlock_ruby_quest_reward.emit()

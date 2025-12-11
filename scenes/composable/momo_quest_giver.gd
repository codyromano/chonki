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
	# Check pottery count when building dialogue tree
	var pottery_count = _count_pottery_pieces()
	var reward_given = _get_quest_state("momo_reward_given")
	
	var momo_tree = DialogueTree.new()
	
	# If reward has been given, show thank you message
	if reward_given:
		var momo_thanks = DialogueNode.new()
		momo_thanks.text = "Thanks again for helping me find those pottery pieces, Gus!"
		momo_thanks.choices = []
		momo_tree.root_node = momo_thanks
		return momo_tree
	
	# If player has collected all 3 pieces, show completion message
	if pottery_count == 3:
		# Completion dialogue - Part 3
		var momo_complete_part3 = DialogueNode.new()
		momo_complete_part3.text = "In the meantime, take this reward!"
		momo_complete_part3.choices = []
		
		# Completion dialogue - Part 2
		var momo_complete_part2 = DialogueNode.new()
		momo_complete_part2.text = "Maybe we should set up our owners on a playdate sometime. That'd be good for them."
		momo_complete_part2.choices = [
			{"id": "momo-complete-continue-2", "text": "Continue", "next_node": momo_complete_part3}
		]
		
		# Completion dialogue - Part 1
		var momo_complete_part1 = DialogueNode.new()
		momo_complete_part1.text = "You found them! Thanks, Gus!"
		momo_complete_part1.choices = [
			{"id": "momo-complete-continue-1", "text": "Continue", "next_node": momo_complete_part2}
		]
		
		momo_tree.root_node = momo_complete_part1
		return momo_tree
	
	# If player has collected some but not all pieces, show progress message
	if pottery_count > 0 and pottery_count < 3:
		var momo_progress = DialogueNode.new()
		momo_progress.text = "You've collected " + str(pottery_count) + " pieces. Keep going!"
		momo_progress.choices = []
		momo_tree.root_node = momo_progress
		return momo_tree
	
	# Initial quest offer dialogue (no pottery collected yet)
	var momo_accept = DialogueNode.new()
	momo_accept.text = "Thanks for your help! Come back once you've collected all 3 pieces of pottery."
	momo_accept.choices = []

	var momo_decline = DialogueNode.new()
	momo_decline.text = "Oh, that's too bad. Let me know if you change your mind."
	momo_decline.choices = []

	# Initial offer - Part 2
	var momo_offer_part2 = DialogueNode.new()
	momo_offer_part2.text = "Sadly, she lost 3 of her favorite pieces around Green Lake... Will you help me find them?"
	momo_offer_part2.choices = [
		{"id": "momo-accept", "text": "Yes, I'll help!", "next_node": momo_accept},
		{"id": "momo-decline", "text": "No, sorry.", "next_node": momo_decline}
	]

	# Initial offer - Part 1
	var momo_offer_part1 = DialogueNode.new()
	momo_offer_part1.text = "Did your owner pick up any hobbies during quarantine? Mine got *obsessed* with pottery."
	momo_offer_part1.choices = [
		{"id": "momo-continue-1", "text": "Continue", "next_node": momo_offer_part2}
	]

	momo_tree.root_node = momo_offer_part1
	return momo_tree

func _count_pottery_pieces() -> int:
	var count = 0
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_1):
		count += 1
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_2):
		count += 1
	if PlayerInventory.has_item(PlayerInventory.Item.POTTERY_3):
		count += 1
	return count

# Override to handle quest acceptance
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	# Track quest acceptance
	if selected_option_id == "momo-accept":
		_set_quest_state("momo_quest_accepted", true)
		PlayerInventory.add_item(PlayerInventory.Item.MOMO_QUEST)
	
	# Proceed with normal dialogue flow 
	return get_next_dialogue_node(current_node, selected_option_id)

func on_dialogue_finished() -> void:
	var reward_given = _get_quest_state("momo_reward_given")
	if _count_pottery_pieces() == 3 and not reward_given:
		_set_quest_state("momo_reward_given", true)
		GlobalSignals.spawn_item_in_location.emit(PlayerInventory.Item.SECRET_LETTER_R)

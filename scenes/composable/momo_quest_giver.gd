extends "res://scenes/quest_giver.gd"

var quest_accepted: bool = false

func _get_dialogue_tree() -> DialogueTree:
	# Check pottery count when building dialogue tree
	var pottery_count = _count_pottery_pieces()
	
	var momo_tree = DialogueTree.new()
	
	# If player has collected all 3 pieces, show completion message
	if pottery_count == 3:
		var momo_complete = DialogueNode.new()
		momo_complete.text = "Thanks for your help! Here...take this reward!"
		momo_complete.choices = []
		momo_tree.root_node = momo_complete
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

	var momo_offer = DialogueNode.new()
	momo_offer.text = "Hello! I lost some pieces of pottery. Can you help me find them?"
	momo_offer.choices = [
		{"id": "momo-accept", "text": "Yes, I'll help!", "next_node": momo_accept},
		{"id": "momo-decline", "text": "No, sorry.", "next_node": momo_decline}
	]

	momo_tree.root_node = momo_offer
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
		quest_accepted = true
		PlayerInventory.add_item(PlayerInventory.Item.MOMO_QUEST)
		# Spawn pottery collectibles
		GlobalSignals.spawn_item_in_location.emit(PlayerInventory.Item.POTTERY_1)
		GlobalSignals.spawn_item_in_location.emit(PlayerInventory.Item.POTTERY_2)
		GlobalSignals.spawn_item_in_location.emit(PlayerInventory.Item.POTTERY_3)
	
	# Proceed with normal dialogue flow
	return get_next_dialogue_node(current_node, selected_option_id)

func on_dialogue_finished() -> void:
	# Check if all pottery pieces have been collected
	if _count_pottery_pieces() == 3:
		# Spawn secret letter X as a reward
		GlobalSignals.spawn_item_in_location.emit(PlayerInventory.Item.SECRET_LETTER_X)

extends "res://scenes/quest_giver.gd"

func _get_dialogue_tree() -> DialogueTree:
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

	var momo_tree = DialogueTree.new()
	momo_tree.root_node = momo_offer
	return momo_tree
	
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	return get_next_dialogue_node(current_node, selected_option_id)

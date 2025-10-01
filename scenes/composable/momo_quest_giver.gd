extends "res://scenes/quest_giver.gd"

func _get_dialogue_tree() -> DialogueTree:
	var momo_accept = DialogueNode.new()
	momo_accept.text = "Thank you! Please bring them back if you find any."
	momo_accept.choices = []

	var momo_decline = DialogueNode.new()
	momo_decline.text = "Oh, that's too bad. Let me know if you change your mind."
	momo_decline.choices = []

	var momo_offer = DialogueNode.new()
	momo_offer.text = "Hello! I lost some pieces of pottery. Can you help me find them?"
	momo_offer.choices = [
		{"text": "Yes, I'll help!", "next_node": momo_accept},
		{"text": "No, sorry.", "next_node": momo_decline}
	]

	var momo_tree = DialogueTree.new()
	momo_tree.root_node = momo_offer
	return momo_tree

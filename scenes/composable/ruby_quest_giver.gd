extends "res://scenes/quest_giver.gd"

func _get_dialogue_tree() -> DialogueTree:
	# Dialogue 2 - When Gus returns the ball (completion dialogue)
	var ruby_thanks = DialogueNode.new()
	ruby_thanks.text = "Whoa, you found it! You are officially promoted to Captain Corgi of the Sky-Serve Squad.\n\nYou know, I think I forgot how to talk to people. My first full sentence this week was to a vending machine. It did not respond well to feedback.\n\nStill… maybe this is how it starts again. A lost ball, a found friend, a reminder that the city's still full of bounce.\n\nThanks, Gus. If you ever need a sub for beach volleyball—or emotional support—I'm your girl."
	ruby_thanks.choices = []
	
	# Dialogue 1 - First encounter (quest offer) - Part 3
	var ruby_intro_part3 = DialogueNode.new()
	ruby_intro_part3.text = "I've been coming here every weekend since… well, since the city started breathing again. It's weird—I used to hate crowds. Now I miss strangers. Anyway! Ball first, therapy later."
	ruby_intro_part3.choices = []
	
	# Dialogue 1 - First encounter (quest offer) - Part 2
	var ruby_intro_part2 = DialogueNode.new()
	ruby_intro_part2.text = "So, um… my volleyball's gone rogue. Last seen bouncing off that ledge like it was late for a meeting. If you happen to sniff it out, I'll owe you… one lifetime supply of imaginary high-fives."
	ruby_intro_part2.choices = [
		{"id": "ruby-continue-2", "text": "[Continue]", "next_node": ruby_intro_part3}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 1
	var ruby_intro_part1 = DialogueNode.new()
	ruby_intro_part1.text = "Wait—hold on! You're not a flying corgi, are you? No wings? Okay, that's fine, we'll improvise."
	ruby_intro_part1.choices = [
		{"id": "ruby-continue-1", "text": "[Continue]", "next_node": ruby_intro_part2}
	]

	var ruby_tree = DialogueTree.new()
	ruby_tree.root_node = ruby_intro_part1
	return ruby_tree
	
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	return get_next_dialogue_node(current_node, selected_option_id)

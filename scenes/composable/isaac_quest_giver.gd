extends "res://scenes/quest_giver.gd"

var eagle_returned: bool = false

func _get_dialogue_tree() -> DialogueTree:
	# Dialogue 2 - When Gus returns the eagle (completion dialogue) - Part 3
	var isaac_thanks_part3 = DialogueNode.new()
	isaac_thanks_part3.text = "You're a lifesaver, Gus. Here—take this as a token of my gratitude."
	isaac_thanks_part3.choices = []
	
	# Dialogue 2 - When Gus returns the eagle (completion dialogue) - Part 2
	var isaac_thanks_part2 = DialogueNode.new()
	isaac_thanks_part2.text = "I promise I'll never use 'air jail' again. Well… maybe not NEVER, but definitely with better planning."
	isaac_thanks_part2.choices = [
		{"id": "isaac-thanks-continue-2", "text": "Continue", "next_node": isaac_thanks_part3}
	]
	
	# Dialogue 2 - When Gus returns the eagle (completion dialogue) - Part 1
	var isaac_thanks_part1 = DialogueNode.new()
	isaac_thanks_part1.text = "You actually brought him back! I hereby promote you to Chief Sky Rescue Officer."
	isaac_thanks_part1.choices = [
		{"id": "isaac-thanks-continue-1", "text": "Continue", "next_node": isaac_thanks_part2}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 4
	var isaac_intro_part4 = DialogueNode.new()
	isaac_intro_part4.text = "Look, I know 'air jail' sounds bad. But in my defense, he WAS throwing rocks at the mailman. I just… didn't think about the geese situation."
	isaac_intro_part4.choices = []
	
	# Dialogue 1 - First encounter (quest offer) - Part 3
	var isaac_intro_part3 = DialogueNode.new()
	isaac_intro_part3.text = "The clouds up there are overrun with angry geese. Every time I try to fly up, they chase me off. It's like they formed a union or something."
	isaac_intro_part3.choices = [
		{"id": "isaac-continue-3", "text": "Continue", "next_node": isaac_intro_part4}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 2
	var isaac_intro_part2 = DialogueNode.new()
	isaac_intro_part2.text = "So here's the thing… I put my son in 'air jail' on a cloud platform up there. Yeah, I know. Parent of the year, right?"
	isaac_intro_part2.choices = [
		{"id": "isaac-continue-2", "text": "Continue", "next_node": isaac_intro_part3}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 1
	var isaac_intro_part1 = DialogueNode.new()
	isaac_intro_part1.text = "Hey! You look like someone who doesn't judge questionable parenting decisions. Can I level with you for a second?"
	isaac_intro_part1.choices = [
		{"id": "isaac-continue-1", "text": "Continue", "next_node": isaac_intro_part2}
	]

	var isaac_tree = DialogueTree.new()
	# Choose root based on whether eagle has been returned
	if eagle_returned:
		isaac_tree.root_node = isaac_thanks_part1
	else:
		isaac_tree.root_node = isaac_intro_part1
	return isaac_tree
	
func get_next_dialogue_node_custom(current_node: DialogueNode, selected_option_id: String) -> DialogueNode:
	return get_next_dialogue_node(current_node, selected_option_id)

func _on_body_entered_override(body: Node2D) -> void:
	# Check if the body is the baby eagle
	if body.name == "BabyEagle":
		# Mark that eagle has been returned
		eagle_returned = true
		# Reset dialogue to show the thank you dialogue
		current_dialogue_node = null
		
		# Create a tween to fade out the eagle
		var tween = create_tween()
		tween.tween_property(body, "modulate:a", 0.0, 1.0)
		await tween.finished
		# Queue free deferred after fade completes
		body.queue_free()
		
		sprite.play('happy')

func on_dialogue_finished() -> void:
	# Only emit signal if eagle has been returned (completion dialogue was shown)
	if eagle_returned:
		GlobalSignals.unlock_isaac_quest_reward.emit()

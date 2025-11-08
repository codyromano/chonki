extends "res://scenes/quest_giver.gd"

var eagle_returned: bool = false
var has_met_isaac: bool = false

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
	isaac_intro_part4.text = "Rodrigo's trapped in air jail. Please help me, Gus..."
	isaac_intro_part4.choices = []
	
	# Dialogue 1 - First encounter (quest offer) - Part 3
	var isaac_intro_part3 = DialogueNode.new()
	isaac_intro_part3.text = "But angry geese surrounded his timeout cloud."
	isaac_intro_part3.choices = [
		{"id": "isaac-continue-3", "text": "Continue", "next_node": isaac_intro_part4}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 2
	var isaac_intro_part2 = DialogueNode.new()
	isaac_intro_part2.text = "I put him in timeout for pooping on the cyclists."
	isaac_intro_part2.choices = [
		{"id": "isaac-continue-2", "text": "Continue", "next_node": isaac_intro_part3}
	]
	
	# Dialogue 1 - First encounter (quest offer) - Part 1
	var isaac_intro_part1 = DialogueNode.new()
	isaac_intro_part1.text = "My poor baby Rodrigo is trapped!"
	isaac_intro_part1.choices = [
		{"id": "isaac-continue-1", "text": "Continue", "next_node": isaac_intro_part2}
	]
	
	# Repeat dialogue - when talking again before finding the eagle
	var isaac_repeat = DialogueNode.new()
	isaac_repeat.text = "Have you found my baby Rodrigo?"
	isaac_repeat.choices = []

	var isaac_tree = DialogueTree.new()
	# Choose root based on whether eagle has been returned
	if eagle_returned:
		isaac_tree.root_node = isaac_thanks_part1
	elif has_met_isaac:
		isaac_tree.root_node = isaac_repeat
	else:
		isaac_tree.root_node = isaac_intro_part1
		has_met_isaac = true
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

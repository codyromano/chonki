@tool
extends Node2D

var previous_scene_path: String = ""

func _ready():
	previous_scene_path = FadeTransition._previous_scene_path
	show_score()
	# Connect Replay button
	var replay_btn = get_node_or_null("Control/ButtonContainer/HBoxContainer/Replay")
	if replay_btn:
		replay_btn.pressed.connect(_on_replay_pressed)

func show_score():
	# Use GameState singleton for persistent data
	var collected = GameState.stars_collected
	var total_stars = GameState.total_stars
	var time = GameState.time_elapsed

	# Clamp total_stars to at least 1 to avoid division by zero
	if total_stars <= 0:
		total_stars = collected

	# Get per-level time thresholds
	var level_path = FadeTransition._previous_scene_path
	var thresholds = GameState.get_time_thresholds_for_level(level_path)
	var perfect_time = thresholds["perfect"]
	var great_time = thresholds["great"]
	var okay_time = thresholds["okay"]

	# Determine rank
	var rank = "Okay"
	if collected == total_stars and time <= perfect_time:
		rank = "Perfect"
	elif collected >= int(total_stars * 0.5) and time <= great_time:
		rank = "Great"
	elif time <= okay_time:
		rank = "Okay"

	# Update UI
	var label = get_node_or_null("Control/VBoxContainer/HBoxContainer/Label")
	if label:
		label.text = rank
	var star_label2 = get_node_or_null("Control/StarContainer/HBoxContainer2/Label2")
	if star_label2:
		star_label2.text = "%d/%d" % [collected, total_stars]
	var time_label2 = get_node_or_null("Control/TimeContainer/HBoxContainer2/Label2")
	if time_label2:
		time_label2.text = str(time)

	# Update the long description for next rank (only show the next achievable rank)
	var desc_label = get_node_or_null("Control/VBoxContainer2/HBoxContainer/Label")
	if desc_label:
		if rank == "Okay":
			desc_label.text = "Collect at least %d stars and finish in under %d seconds for a \"Great\" rank." % [int(total_stars * 0.5), great_time]
		elif rank == "Great":
			desc_label.text = "Collect all %d stars in under %d seconds to achieve \"perfection.\"" % [total_stars, perfect_time]
		elif rank == "Perfect":
			desc_label.text = "You achieved perfection!"

func _on_replay_pressed():
	FadeTransition.fade_out_and_change_scene(previous_scene_path, 0.0, 1.0)

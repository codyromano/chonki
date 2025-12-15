extends GutTest

var intro_scene = preload("res://scenes/intro.tscn")
var intro: Node2D

func before_each():
	intro = intro_scene.instantiate()
	add_child_autofree(intro)
	await wait_physics_frames(1)

func after_each():
	intro = null

func test_intro_has_five_secret_letters():
	var story_letters = intro.get_node_or_null("Items/StoryLetters")
	assert_not_null(story_letters, "Items/StoryLetters node should exist")
	
	var letter_count = 0
	for child in story_letters.get_children():
		if child.name.begins_with("SecretLetter"):
			letter_count += 1
	
	assert_eq(letter_count, 5, "Should have exactly 5 SecretLetter nodes in intro.tscn")

func test_intro_total_secret_letters_matches_five():
	await wait_physics_frames(2)
	
	var story_letters = intro.get_node_or_null("Items/StoryLetters")
	var letter_count = 0
	for child in story_letters.get_children():
		if child.name.begins_with("SecretLetter"):
			letter_count += 1
	
	assert_eq(letter_count, 5, "Should have exactly 5 secret letter nodes matching the unified system")

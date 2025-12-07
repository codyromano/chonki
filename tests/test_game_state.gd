extends GutTest

func before_each():
	GameState.current_level = 1
	GameState.stars_collected = 0
	GameState.total_stars = 0
	GameState.time_elapsed = 0.0
	GameState.stars_per_level.clear()
	GameState.triggered_instruction_triggers.clear()
	GameState.letters_collected_by_scene = {1: [], 2: []}

func after_each():
	pass

func test_reset_clears_stars_collected():
	GameState.stars_collected = 10
	GameState.reset()
	assert_eq(GameState.stars_collected, 0, "Reset should clear stars_collected")

func test_reset_clears_time_elapsed():
	GameState.time_elapsed = 45.5
	GameState.reset()
	assert_eq(GameState.time_elapsed, 0.0, "Reset should clear time_elapsed")

func test_set_total_stars_for_level_caches_by_path():
	var level_path = "res://scenes/level1.tscn"
	GameState.set_total_stars_for_level(level_path, 15)
	assert_eq(GameState.stars_per_level[level_path], 15, "Should cache star count by level path")

func test_set_total_stars_for_level_updates_total_stars():
	GameState.set_total_stars_for_level("res://scenes/test_level.tscn", 20)
	assert_eq(GameState.total_stars, 20, "Should update total_stars property")

func test_get_total_stars_for_level_retrieves_cached_value():
	var level_path = "res://scenes/bonus.tscn"
	GameState.set_total_stars_for_level(level_path, 8)
	var retrieved = GameState.get_total_stars_for_level(level_path)
	assert_eq(retrieved, 8, "Should retrieve cached star count")

func test_get_total_stars_for_level_returns_zero_if_not_cached():
	var result = GameState.get_total_stars_for_level("res://scenes/uncached_level.tscn")
	assert_eq(result, 0, "Should return 0 for uncached level")

func test_get_total_stars_for_level_updates_total_stars_property():
	GameState.set_total_stars_for_level("res://scenes/cached.tscn", 12)
	GameState.total_stars = 0
	GameState.get_total_stars_for_level("res://scenes/cached.tscn")
	assert_eq(GameState.total_stars, 12, "Should update total_stars when retrieving cached value")

func test_get_time_thresholds_for_level_returns_custom_thresholds():
	var level_path = "res://scenes/level1.tscn"
	var thresholds = GameState.get_time_thresholds_for_level(level_path)
	assert_eq(thresholds["perfect"], 20, "Should return custom perfect threshold")
	assert_eq(thresholds["great"], 80, "Should return custom great threshold")
	assert_eq(thresholds["okay"], 90, "Should return custom okay threshold")

func test_get_time_thresholds_for_level_returns_defaults_for_unknown_level():
	var level_path = "res://scenes/unknown_level.tscn"
	var thresholds = GameState.get_time_thresholds_for_level(level_path)
	assert_eq(thresholds["perfect"], 60, "Should return default perfect threshold")
	assert_eq(thresholds["great"], 80, "Should return default great threshold")
	assert_eq(thresholds["okay"], 90, "Should return default okay threshold")

func test_add_collected_letter_appends_to_current_level():
	GameState.current_level = 1
	GameState.add_collected_letter("A")
	GameState.add_collected_letter("D")
	var letters = GameState.get_collected_letters()
	assert_eq(letters.size(), 2, "Should have 2 letters")
	assert_true(letters.has("A"), "Should contain letter A")
	assert_true(letters.has("D"), "Should contain letter D")

func test_get_collected_letters_returns_letters_for_current_level():
	GameState.current_level = 2
	GameState.add_collected_letter("F")
	var letters = GameState.get_collected_letters()
	assert_eq(letters.size(), 1, "Should have 1 letter for level 2")
	assert_true(letters.has("F"), "Should contain letter F")

func test_letters_are_isolated_between_levels():
	GameState.current_level = 1
	GameState.add_collected_letter("X")
	GameState.current_level = 2
	var letters_level_2 = GameState.get_collected_letters()
	assert_eq(letters_level_2.size(), 0, "Level 2 should not have level 1's letters")

func test_get_current_level_puzzle_solution_returns_correct_solution():
	GameState.current_level = 1
	var solution = GameState.get_current_level_puzzle_solution()
	assert_eq(solution, "adopt", "Should return 'adopt' for level 1")

func test_get_current_level_puzzle_solution_for_level_2():
	GameState.current_level = 2
	var solution = GameState.get_current_level_puzzle_solution()
	assert_eq(solution, "fresh", "Should return 'fresh' for level 2")

func test_is_instruction_trigger_used_returns_false_for_new_trigger():
	var is_used = GameState.is_instruction_trigger_used("new_trigger_id")
	assert_false(is_used, "Should return false for unused trigger")

func test_mark_instruction_trigger_used_sets_trigger_to_true():
	GameState.mark_instruction_trigger_used("tutorial_1")
	var is_used = GameState.is_instruction_trigger_used("tutorial_1")
	assert_true(is_used, "Should return true after marking as used")

func test_instruction_triggers_persist_across_queries():
	GameState.mark_instruction_trigger_used("hint_1")
	GameState.mark_instruction_trigger_used("hint_2")
	assert_true(GameState.is_instruction_trigger_used("hint_1"), "First trigger should remain true")
	assert_true(GameState.is_instruction_trigger_used("hint_2"), "Second trigger should be true")

func test_multiple_levels_can_cache_different_star_counts():
	GameState.set_total_stars_for_level("res://scenes/level1.tscn", 10)
	GameState.set_total_stars_for_level("res://scenes/level2.tscn", 15)
	GameState.set_total_stars_for_level("res://scenes/bonus.tscn", 5)
	
	assert_eq(GameState.get_total_stars_for_level("res://scenes/level1.tscn"), 10)
	assert_eq(GameState.get_total_stars_for_level("res://scenes/level2.tscn"), 15)
	assert_eq(GameState.get_total_stars_for_level("res://scenes/bonus.tscn"), 5)

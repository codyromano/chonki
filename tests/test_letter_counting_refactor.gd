extends GutTest

func before_each():
	PlayerInventory.clear_inventory()
	GameState.current_level = 1
	GameState.collected_letter_items_by_level = {1: [], 2: []}

func test_intro_level_letter_counting():
	GameState.current_level = 1
	GameState.collected_letter_items_by_level[1] = [
		PlayerInventory.Item.SECRET_LETTER_A,
		PlayerInventory.Item.SECRET_LETTER_D,
		PlayerInventory.Item.SECRET_LETTER_O
	]
	assert_eq(PlayerInventory.get_collected_secret_letter_count(), 3, "Should count 3 letters in intro level")

func test_level1_letter_counting():
	GameState.current_level = 2
	GameState.collected_letter_items_by_level[2] = [
		PlayerInventory.Item.SECRET_LETTER_F,
		PlayerInventory.Item.SECRET_LETTER_R,
		PlayerInventory.Item.SECRET_LETTER_E,
		PlayerInventory.Item.SECRET_LETTER_S,
		PlayerInventory.Item.SECRET_LETTER_H
	]
	assert_eq(PlayerInventory.get_collected_secret_letter_count(), 5, "Should count 5 letters in level1")

func test_letter_count_is_level_specific():
	GameState.collected_letter_items_by_level[1] = [
		PlayerInventory.Item.SECRET_LETTER_A,
		PlayerInventory.Item.SECRET_LETTER_D
	]
	GameState.collected_letter_items_by_level[2] = [
		PlayerInventory.Item.SECRET_LETTER_F,
		PlayerInventory.Item.SECRET_LETTER_R,
		PlayerInventory.Item.SECRET_LETTER_E
	]
	
	GameState.current_level = 1
	assert_eq(PlayerInventory.get_collected_secret_letter_count(), 2, "Should only count intro letters when in intro")
	
	GameState.current_level = 2
	assert_eq(PlayerInventory.get_collected_secret_letter_count(), 3, "Should only count level1 letters when in level1")

func test_empty_level_returns_zero():
	GameState.current_level = 1
	GameState.collected_letter_items_by_level[1] = []
	assert_eq(PlayerInventory.get_collected_secret_letter_count(), 0, "Should return 0 for empty level")

func test_all_adopt_letters_mapped():
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_A), "A")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_D), "D")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_O), "O")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_P), "P")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_T), "T")

func test_all_fresh_letters_mapped():
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_F), "F")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_R), "R")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_E), "E")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_S), "S")
	assert_eq(GameState.get_letter_string_from_item(PlayerInventory.Item.SECRET_LETTER_H), "H")

func test_dave_win_condition_intro():
	GameState.current_level = 1
	GameState.collected_letter_items_by_level[1] = [
		PlayerInventory.Item.SECRET_LETTER_A,
		PlayerInventory.Item.SECRET_LETTER_D,
		PlayerInventory.Item.SECRET_LETTER_O,
		PlayerInventory.Item.SECRET_LETTER_P,
		PlayerInventory.Item.SECRET_LETTER_T
	]
	assert_true(PlayerInventory.get_collected_secret_letter_count() >= 5, "Should satisfy Dave win condition with all 5 intro letters")

func test_dave_win_condition_level1():
	GameState.current_level = 2
	GameState.collected_letter_items_by_level[2] = [
		PlayerInventory.Item.SECRET_LETTER_F,
		PlayerInventory.Item.SECRET_LETTER_R,
		PlayerInventory.Item.SECRET_LETTER_E,
		PlayerInventory.Item.SECRET_LETTER_S,
		PlayerInventory.Item.SECRET_LETTER_H
	]
	assert_true(PlayerInventory.get_collected_secret_letter_count() >= 5, "Should satisfy Dave win condition with all 5 level1 letters")

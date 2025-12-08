extends GutTest

var heart_lost_count: int = 0
var player_out_of_hearts_emitted: bool = false

func before_each():
	PlayerInventory.items.clear()
	PlayerInventory.total_hearts = PlayerInventory.INITIAL_HEARTS
	PlayerInventory.last_damage_source = ""
	PlayerInventory.earned_midair_jumps = 0
	heart_lost_count = 0
	player_out_of_hearts_emitted = false
	
	GlobalSignals.connect("heart_lost", _on_heart_lost)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)

func after_each():
	if GlobalSignals.is_connected("heart_lost", _on_heart_lost):
		GlobalSignals.disconnect("heart_lost", _on_heart_lost)
	if GlobalSignals.is_connected("player_out_of_hearts", _on_player_out_of_hearts):
		GlobalSignals.disconnect("player_out_of_hearts", _on_player_out_of_hearts)

func _on_heart_lost():
	heart_lost_count += 1

func _on_player_out_of_hearts():
	player_out_of_hearts_emitted = true

func test_initial_hearts_is_three():
	assert_eq(PlayerInventory.INITIAL_HEARTS, 3, "Initial hearts should be 3")

func test_get_total_hearts_returns_current_hearts():
	PlayerInventory.total_hearts = 2
	assert_eq(PlayerInventory.get_total_hearts(), 2, "Should return current heart count")

func test_remove_heart_decrements_hearts():
	var initial = PlayerInventory.get_total_hearts()
	PlayerInventory.remove_heart()
	assert_eq(PlayerInventory.get_total_hearts(), initial - 1, "Should decrement hearts by 1")

func test_remove_heart_emits_heart_lost_signal():
	PlayerInventory.remove_heart()
	assert_eq(heart_lost_count, 1, "Should emit heart_lost signal once")

func test_remove_heart_at_zero_does_not_go_negative():
	PlayerInventory.total_hearts = 0
	PlayerInventory.remove_heart()
	assert_eq(PlayerInventory.get_total_hearts(), 0, "Hearts should not go negative")

func test_remove_heart_at_zero_does_not_emit_heart_lost():
	PlayerInventory.total_hearts = 0
	PlayerInventory.remove_heart()
	assert_eq(heart_lost_count, 0, "Should not emit heart_lost when already at 0")

func test_remove_heart_to_zero_emits_player_out_of_hearts():
	PlayerInventory.total_hearts = 1
	PlayerInventory.remove_heart()
	assert_true(player_out_of_hearts_emitted, "Should emit player_out_of_hearts when reaching 0")

func test_reset_hearts_restores_to_initial():
	PlayerInventory.total_hearts = 1
	PlayerInventory.reset_hearts()
	assert_eq(PlayerInventory.get_total_hearts(), PlayerInventory.INITIAL_HEARTS, "Should restore to initial hearts")

func test_player_hit_signal_stores_damage_source():
	GlobalSignals.player_hit.emit("ocean")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.last_damage_source, "ocean", "Should store damage source")

func test_player_hit_signal_removes_heart():
	var initial = PlayerInventory.get_total_hearts()
	GlobalSignals.player_hit.emit("enemy")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.get_total_hearts(), initial - 1, "Player hit should remove a heart")

func test_add_item_adds_to_inventory():
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
	assert_true(PlayerInventory.has_item(PlayerInventory.Item.POTTERY_1), "Should add item to inventory")

func test_add_item_prevents_duplicates():
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
	assert_eq(PlayerInventory.get_item_count(), 1, "Should not add duplicate items")

func test_remove_item_removes_from_inventory():
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_2)
	var removed = PlayerInventory.remove_item(PlayerInventory.Item.POTTERY_2)
	assert_true(removed, "Should return true when item removed")
	assert_false(PlayerInventory.has_item(PlayerInventory.Item.POTTERY_2), "Item should be removed")

func test_remove_item_returns_false_when_not_found():
	var removed = PlayerInventory.remove_item(PlayerInventory.Item.POTTERY_3)
	assert_false(removed, "Should return false when item not in inventory")

func test_has_item_returns_false_for_missing_item():
	assert_false(PlayerInventory.has_item(PlayerInventory.Item.MOMO_QUEST), "Should return false for missing item")

func test_get_items_returns_copy_of_array():
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_F)
	var items = PlayerInventory.get_items()
	items.clear()
	assert_eq(PlayerInventory.get_item_count(), 1, "Modifying returned array should not affect inventory")

func test_clear_inventory_removes_all_items():
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_2)
	PlayerInventory.clear_inventory()
	assert_eq(PlayerInventory.get_item_count(), 0, "Should remove all items")

func test_clear_inventory_resets_earned_midair_jumps():
	PlayerInventory.earned_midair_jumps = 5
	PlayerInventory.clear_inventory()
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 0, "Should reset earned midair jumps")

func test_reset_hearts_does_not_affect_midair_jumps():
	PlayerInventory.earned_midair_jumps = 3
	PlayerInventory.reset_hearts()
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 3, "Reset hearts should not affect midair jumps")

func test_reset_hearts_does_not_affect_inventory():
	PlayerInventory.add_item(PlayerInventory.Item.SECRET_LETTER_H)
	PlayerInventory.reset_hearts()
	assert_true(PlayerInventory.has_item(PlayerInventory.Item.SECRET_LETTER_H), "Reset hearts should not clear inventory")

func test_increment_midair_jumps_increases_count():
	var initial = PlayerInventory.get_earned_midair_jumps()
	PlayerInventory.increment_midair_jumps()
	assert_eq(PlayerInventory.get_earned_midair_jumps(), initial + 1, "Should increment midair jumps")

func test_get_item_count_returns_correct_count():
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_1)
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_2)
	PlayerInventory.add_item(PlayerInventory.Item.POTTERY_3)
	assert_eq(PlayerInventory.get_item_count(), 3, "Should return correct item count")

func test_multiple_hits_deplete_hearts_correctly():
	assert_eq(PlayerInventory.get_total_hearts(), 3, "Should start with 3 hearts")
	
	GlobalSignals.player_hit.emit("enemy")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.get_total_hearts(), 2, "Should have 2 hearts after first hit")
	
	GlobalSignals.player_hit.emit("enemy")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.get_total_hearts(), 1, "Should have 1 heart after second hit")
	
	GlobalSignals.player_hit.emit("enemy")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.get_total_hearts(), 0, "Should have 0 hearts after third hit")
	assert_true(player_out_of_hearts_emitted, "Should emit player_out_of_hearts")

func test_ocean_damage_tracks_source():
	GlobalSignals.player_hit.emit("ocean")
	GlobalSignals.player_hit.emit("ocean")
	GlobalSignals.player_hit.emit("ocean")
	await wait_physics_frames(1)
	assert_eq(PlayerInventory.last_damage_source, "ocean", "Should track ocean as damage source")

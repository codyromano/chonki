extends GutTest

func before_each():
	PlayerInventory.earned_midair_jumps = 0

func after_each():
	PlayerInventory.earned_midair_jumps = 0

func test_midair_jumps_increment_on_secret_letter():
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 0, "Should start at 0")
	
	PlayerInventory.increment_midair_jumps()
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 1, "Should be 1 after increment")
	
	PlayerInventory.increment_midair_jumps()
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 2, "Should be 2 after second increment")

func test_midair_jumps_persist_through_reset_hearts():
	PlayerInventory.increment_midair_jumps()
	PlayerInventory.increment_midair_jumps()
	PlayerInventory.increment_midair_jumps()
	
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 3, "Should have 3 midair jumps")
	
	PlayerInventory.reset_hearts()
	
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 3, "Midair jumps should persist after reset_hearts")
	assert_eq(PlayerInventory.get_total_hearts(), 3, "Hearts should be reset to 3")

func test_midair_jumps_reset_on_clear_inventory():
	PlayerInventory.increment_midair_jumps()
	PlayerInventory.increment_midair_jumps()
	
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 2, "Should have 2 midair jumps")
	
	PlayerInventory.clear_inventory()
	
	assert_eq(PlayerInventory.get_earned_midair_jumps(), 0, "Midair jumps should be reset to 0 after clear_inventory")

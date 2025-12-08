extends GutTest

var elevator_script = preload("res://scenes/CloudBarrierElevator.gd")
var goose_script = preload("res://scenes/GooseBossCloudMaze.gd")
var elevator: Area2D
var goose: Area2D

func before_each():
	elevator = Area2D.new()
	elevator.set_script(elevator_script)
	elevator.name = "CloudBarrierElevator"
	
	var arrow_left = Label.new()
	arrow_left.name = "ArrowLeft"
	elevator.add_child(arrow_left)
	
	var arrow_right = Label.new()
	arrow_right.name = "ArrowRight"
	elevator.add_child(arrow_right)
	
	var arrow_up = Label.new()
	arrow_up.name = "ArrowUp"
	elevator.add_child(arrow_up)
	
	var arrow_down = Label.new()
	arrow_down.name = "ArrowDown"
	elevator.add_child(arrow_down)
	
	goose = Area2D.new()
	goose.set_script(goose_script)
	goose.name = "GooseBossCloudMaze"
	
	var goose_sprite = AnimatedSprite2D.new()
	goose_sprite.name = "AnimatedSprite2D"
	goose.add_child(goose_sprite)
	
	var goose_collision = CollisionShape2D.new()
	goose_collision.name = "CollisionShape2D"
	goose.add_child(goose_collision)
	
	add_child_autofree(elevator)
	add_child_autofree(goose)
	
	elevator._ready()
	goose._ready()

func after_each():
	elevator = null
	goose = null

func test_elevator_starts_with_initial_direction():
	assert_eq(elevator.direction_horizontal, -1, "Should start with left direction")
	assert_eq(elevator.direction_vertical, -1, "Should start with up direction")

func test_elevator_starts_unpowered():
	assert_false(elevator.is_powered, "Should start unpowered")
	assert_false(elevator.is_returning, "Should start not returning")

func test_elevator_stores_initial_position():
	var initial_pos = elevator.position
	assert_eq(elevator.initial_position, initial_pos, "Should store initial position")

func test_goose_starts_not_defeated():
	assert_false(goose.defeat_triggered, "Goose should start not defeated")

func test_elevator_powers_on_with_power_lever():
	GlobalSignals.lever_status_changed.emit("CloudLeverPower", true)
	await wait_physics_frames(1)
	assert_true(elevator.is_powered, "Should power on with CloudLeverPower")

func test_elevator_toggles_horizontal_direction():
	var initial_dir = elevator.direction_horizontal
	GlobalSignals.lever_status_changed.emit("CloudLeverLeftOrRight", true)
	await wait_physics_frames(1)
	assert_eq(elevator.direction_horizontal, -initial_dir, "Should toggle horizontal direction")

func test_elevator_toggles_vertical_direction():
	var initial_dir = elevator.direction_vertical
	GlobalSignals.lever_status_changed.emit("CloudLeverUpOrDown", true)
	await wait_physics_frames(1)
	assert_eq(elevator.direction_vertical, -initial_dir, "Should toggle vertical direction")

func test_elevator_moves_when_powered():
	var initial_pos = elevator.position
	GlobalSignals.lever_status_changed.emit("CloudLeverPower", true)
	await wait_physics_frames(10)
	assert_ne(elevator.position, initial_pos, "Should move when powered")

func test_elevator_collision_with_goose_triggers_defeat():
	elevator._on_area_entered(goose)
	assert_true(elevator.goose_defeated, "Elevator should mark goose as defeated")
	assert_true(goose.defeat_triggered, "Goose should be triggered for defeat")

func test_goose_defeat_disables_collision():
	goose.trigger_defeat()
	await wait_physics_frames(1)
	assert_false(goose.get_collision_layer_value(2), "Should disable collision layer 2")
	assert_false(goose.get_collision_mask_value(1), "Should disable collision mask 1")

func test_goose_defeat_starts_fade_animation():
	var initial_alpha = goose.modulate.a
	goose.trigger_defeat()
	await wait_seconds(0.1)
	assert_lt(goose.modulate.a, initial_alpha, "Should start fading after defeat")

func test_elevator_only_triggers_defeat_once():
	elevator._on_area_entered(goose)
	var first_defeat_value = goose.defeat_triggered
	elevator._on_area_entered(goose)
	assert_eq(goose.defeat_triggered, first_defeat_value, "Should not trigger defeat multiple times")

func test_elevator_ignores_collision_after_goose_defeated():
	elevator._on_area_entered(goose)
	var first_defeat = goose.defeat_triggered
	elevator._on_area_entered(goose)
	assert_true(first_defeat, "Goose should remain defeated after first collision")

func test_elevator_returns_to_initial_position():
	var initial_pos = elevator.initial_position
	elevator.position = Vector2(1000, 1000)
	elevator._start_return()
	await wait_seconds(5)
	assert_almost_eq(elevator.position.x, initial_pos.x, 10.0, "Should return to initial X position")
	assert_almost_eq(elevator.position.y, initial_pos.y, 10.0, "Should return to initial Y position")

func test_elevator_cannot_power_while_returning():
	elevator.is_returning = true
	GlobalSignals.lever_status_changed.emit("CloudLeverPower", true)
	await wait_physics_frames(1)
	assert_false(elevator.is_powered, "Should not power on while returning")

func test_elevator_cannot_change_direction_while_returning():
	var initial_h = elevator.direction_horizontal
	elevator.is_returning = true
	GlobalSignals.lever_status_changed.emit("CloudLeverLeftOrRight", true)
	await wait_physics_frames(1)
	assert_eq(elevator.direction_horizontal, initial_h, "Should not change direction while returning")

func test_goose_collision_method_exists():
	assert_has_method(goose, "trigger_defeat", "GooseBossCloudMaze should have trigger_defeat method")

func test_elevator_collision_method_exists():
	assert_has_method(elevator, "_on_area_entered", "CloudBarrierElevator should have _on_area_entered method")

func test_goose_has_defeated_state_enum():
	assert_true(goose.has_method("trigger_defeat"), "Should have defeat handling")
	assert_eq(typeof(goose.states), TYPE_DICTIONARY, "Should track states")

func test_elevator_arrows_update_with_direction():
	elevator.direction_horizontal = 1
	elevator.direction_vertical = 1
	elevator._update_arrow_display()
	assert_true(elevator.arrow_right.visible, "Right arrow should be visible")
	assert_true(elevator.arrow_down.visible, "Down arrow should be visible")
	assert_false(elevator.arrow_left.visible, "Left arrow should not be visible")
	assert_false(elevator.arrow_up.visible, "Up arrow should not be visible")

func test_elevator_power_duration_constant_set():
	assert_eq(elevator.POWER_DURATION, 12.0, "Power duration should be 12 seconds")

func test_elevator_return_duration_constant_set():
	assert_eq(elevator.RETURN_DURATION, 4.0, "Return duration should be 4 seconds")

func test_collision_detection_area_to_area():
	assert_true(elevator.is_class("Area2D"), "Elevator should be Area2D")
	assert_true(goose.is_class("Area2D"), "Goose should be Area2D")

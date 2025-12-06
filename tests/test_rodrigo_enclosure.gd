extends GutTest

var rodrigo_script = preload("res://scenes/rodrigo.gd")
var rodrigo: Area2D
var mock_gus_body: CharacterBody2D
var mock_gus_parent: Node2D
var left_wall: Sprite2D
var left_wall_collision: CollisionShape2D
var right_wall: Sprite2D
var right_wall_collision: CollisionShape2D

func before_each():
	rodrigo = Area2D.new()
	rodrigo.set_script(rodrigo_script)
	rodrigo.name = "Rodrigo"
	rodrigo.collision_layer = 2
	rodrigo.collision_mask = 9
	
	var rodrigo_sprite = AnimatedSprite2D.new()
	rodrigo_sprite.name = "RodrigoSprite"
	rodrigo.add_child(rodrigo_sprite)
	
	var rodrigo_collision = CollisionPolygon2D.new()
	rodrigo_collision.name = "CollisionPolygon2D"
	rodrigo.add_child(rodrigo_collision)
	
	left_wall = Sprite2D.new()
	left_wall.name = "LeftWall"
	left_wall.modulate = Color(1, 1, 1, 1)
	
	left_wall_collision = CollisionShape2D.new()
	left_wall_collision.name = "LeftWallCollisionShape"
	
	right_wall = Sprite2D.new()
	right_wall.name = "RightWall"
	right_wall.modulate = Color(1, 1, 1, 1)
	
	right_wall_collision = CollisionShape2D.new()
	right_wall_collision.name = "RightWallCollisionShape"
	
	rodrigo.enclosure_left_wall = left_wall
	rodrigo.enclosure_left_wall_collision = left_wall_collision
	rodrigo.enclosure_right_wall = right_wall
	rodrigo.enclosure_right_wall_collision = right_wall_collision
	
	mock_gus_body = CharacterBody2D.new()
	mock_gus_body.name = "ChonkiCharacter"
	
	mock_gus_parent = Node2D.new()
	mock_gus_parent.name = "GrownUpChonki"
	mock_gus_parent.set_script(preload("res://scenes/grown_up_chonki.gd"))
	mock_gus_parent.carried_entity = null
	mock_gus_parent.add_child(mock_gus_body)
	
	add_child_autofree(rodrigo)
	add_child_autofree(left_wall)
	add_child_autofree(left_wall_collision)
	add_child_autofree(right_wall)
	add_child_autofree(right_wall_collision)
	add_child_autofree(mock_gus_parent)

func after_each():
	rodrigo = null
	mock_gus_parent = null
	mock_gus_body = null
	left_wall = null
	left_wall_collision = null
	right_wall = null
	right_wall_collision = null

func test_rodrigo_has_enclosure_wall_exports():
	assert_not_null(rodrigo.enclosure_left_wall, "Should have left wall export")
	assert_not_null(rodrigo.enclosure_left_wall_collision, "Should have left wall collision export")
	assert_not_null(rodrigo.enclosure_right_wall, "Should have right wall export")
	assert_not_null(rodrigo.enclosure_right_wall_collision, "Should have right wall collision export")

func test_gus_colliding_with_rodrigo_fades_left_wall():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.2)
	assert_lt(left_wall.modulate.a, 1.0, "Left wall should start fading after Gus collision")

func test_gus_colliding_with_rodrigo_fades_right_wall():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.2)
	assert_lt(right_wall.modulate.a, 1.0, "Right wall should start fading after Gus collision")

func test_left_wall_reaches_full_transparency():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_almost_eq(left_wall.modulate.a, 0.0, 0.1, "Left wall should be fully transparent after fade")

func test_right_wall_reaches_full_transparency():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_almost_eq(right_wall.modulate.a, 0.0, 0.1, "Right wall should be fully transparent after fade")

func test_left_wall_removed_after_fade():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_true(is_instance_valid(left_wall) == false or left_wall.is_queued_for_deletion(), "Left wall should be queued for deletion")

func test_right_wall_removed_after_fade():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_true(is_instance_valid(right_wall) == false or right_wall.is_queued_for_deletion(), "Right wall should be queued for deletion")

func test_left_wall_collision_removed_with_wall():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_true(is_instance_valid(left_wall_collision) == false or left_wall_collision.is_queued_for_deletion(), "Left wall collision should be removed")

func test_right_wall_collision_removed_with_wall():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	assert_true(is_instance_valid(right_wall_collision) == false or right_wall_collision.is_queued_for_deletion(), "Right wall collision should be removed")

func test_walls_fade_over_half_second():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.25)
	var mid_fade_alpha = left_wall.modulate.a
	assert_gt(mid_fade_alpha, 0.0, "Walls should still be visible mid-fade")
	assert_lt(mid_fade_alpha, 1.0, "Walls should have started fading")

func test_gus_carries_rodrigo_after_collision():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	assert_eq(mock_gus_parent.carried_entity, rodrigo, "Gus should carry Rodrigo after collision")

func test_rodrigo_collision_disabled_after_pickup():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	assert_false(rodrigo.get_collision_layer_value(1), "Collision layer 1 should be disabled after pickup")
	assert_false(rodrigo.get_collision_mask_value(1), "Collision mask 1 should be disabled after pickup")

func test_walls_fade_at_similar_rate():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.25)
	var left_alpha = left_wall.modulate.a
	var right_alpha = right_wall.modulate.a
	assert_almost_eq(left_alpha, right_alpha, 0.15, "Both walls should fade at similar rates")

func test_both_wall_and_collision_removed_together():
	rodrigo.emit_signal("body_entered", mock_gus_body)
	await wait_seconds(0.6)
	
	var left_wall_valid = is_instance_valid(left_wall)
	var left_collision_valid = is_instance_valid(left_wall_collision)
	
	assert_eq(left_wall_valid, left_collision_valid, "Left wall and its collision should be removed together")

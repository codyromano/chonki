extends GutTest

var rodrigo_script = preload("res://scenes/rodrigo.gd")
var rodrigo: Area2D
var mock_gus_body: CharacterBody2D
var mock_gus_parent: Node2D
var signal_emitted: bool = false

func before_each():
	signal_emitted = false
	
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
	
	mock_gus_body = CharacterBody2D.new()
	mock_gus_body.name = "ChonkiCharacter"
	
	mock_gus_parent = Node2D.new()
	mock_gus_parent.name = "GrownUpChonki"
	mock_gus_parent.set_script(preload("res://scenes/grown_up_chonki.gd"))
	mock_gus_parent.carried_entity = null
	mock_gus_parent.add_child(mock_gus_body)
	
	add_child_autofree(rodrigo)
	add_child_autofree(mock_gus_parent)
	
	GlobalSignals.rodrigo_picked_up.connect(func(): signal_emitted = true)

func after_each():
	if GlobalSignals.rodrigo_picked_up.is_connected(func(): signal_emitted = true):
		GlobalSignals.rodrigo_picked_up.disconnect(func(): signal_emitted = true)
	rodrigo = null
	mock_gus_parent = null
	mock_gus_body = null
	signal_emitted = false

func test_rodrigo_emits_signal_on_gus_collision():
	rodrigo._on_body_entered(mock_gus_body)
	assert_true(signal_emitted, "Should emit rodrigo_picked_up signal when Gus collides")

func test_gus_carries_rodrigo_after_collision():
	rodrigo._on_body_entered(mock_gus_body)
	assert_eq(mock_gus_parent.carried_entity, rodrigo, "Gus should carry Rodrigo after collision")

func test_rodrigo_collision_disabled_after_pickup():
	rodrigo._on_body_entered(mock_gus_body)
	assert_false(rodrigo.get_collision_layer_value(1), "Collision layer 1 should be disabled after pickup")
	assert_false(rodrigo.get_collision_mask_value(1), "Collision mask 1 should be disabled after pickup")

func test_rodrigo_ignores_non_gus_collision():
	var other_body = CharacterBody2D.new()
	other_body.name = "OtherCharacter"
	add_child_autofree(other_body)
	
	rodrigo._on_body_entered(other_body)
	assert_false(signal_emitted, "Should not emit signal for non-Gus collision")
	assert_null(mock_gus_parent.carried_entity, "Gus should not carry anything after non-Gus collision")

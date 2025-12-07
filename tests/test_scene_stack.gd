extends GutTest

var test_scene_1: PackedScene
var test_scene_2: PackedScene

func before_each():
	SceneStack.clear_cache(true)
	SceneStack._stack.clear()
	
	test_scene_1 = PackedScene.new()
	var node1 = Node2D.new()
	node1.name = "TestScene1"
	test_scene_1.pack(node1)
	
	test_scene_2 = PackedScene.new()
	var node2 = Node2D.new()
	node2.name = "TestScene2"
	test_scene_2.pack(node2)

func after_each():
	SceneStack.clear_cache(true)
	SceneStack._stack.clear()

func test_push_scene_returns_new_scene_instance():
	var scene = SceneStack.push_scene(test_scene_1)
	assert_not_null(scene, "Should return scene instance")
	assert_eq(scene.name, "TestScene1", "Should return correct scene")

func test_push_scene_sets_new_scene_as_current():
	var scene = SceneStack.push_scene(test_scene_1)
	assert_eq(get_tree().current_scene, scene, "Should set new scene as current")

func test_push_scene_caches_previous_scene():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	assert_eq(SceneStack._stack.size(), 1, "Should cache previous scene in stack")

func test_push_scene_disables_previous_scene_processing():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	var cached_scene = SceneStack._stack[0]
	assert_eq(cached_scene.process_mode, Node.PROCESS_MODE_DISABLED, "Cached scene should be disabled")

func test_push_scene_makes_previous_scene_invisible():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	var cached_scene = SceneStack._stack[0]
	assert_false(cached_scene.visible, "Cached scene should be invisible")

func test_push_scene_new_scene_is_visible():
	var scene = SceneStack.push_scene(test_scene_1)
	assert_true(scene.visible, "New scene should be visible")

func test_push_scene_new_scene_has_inherit_process_mode():
	var scene = SceneStack.push_scene(test_scene_1)
	assert_eq(scene.process_mode, Node.PROCESS_MODE_INHERIT, "New scene should have inherit process mode")

func test_pop_scene_restores_previous_scene():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	SceneStack.pop_scene(true)
	assert_eq(get_tree().current_scene, initial_scene, "Should restore previous scene as current")

func test_pop_scene_makes_restored_scene_visible():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	SceneStack.pop_scene(true)
	assert_true(initial_scene.visible, "Restored scene should be visible")

func test_pop_scene_enables_restored_scene_processing():
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	SceneStack.pop_scene(true)
	assert_eq(initial_scene.process_mode, Node.PROCESS_MODE_INHERIT, "Restored scene should have inherit process mode")

func test_pop_scene_removes_scene_from_stack():
	SceneStack.push_scene(test_scene_1)
	var stack_size = SceneStack._stack.size()
	SceneStack.pop_scene(true)
	assert_eq(SceneStack._stack.size(), stack_size - 1, "Should remove scene from stack")

func test_pop_scene_on_empty_stack_does_not_crash():
	SceneStack._stack.clear()
	SceneStack.pop_scene(true)
	assert_true(true, "Should handle empty stack gracefully")

func test_multiple_push_operations_stack_correctly():
	SceneStack.push_scene(test_scene_1)
	var stack_size_after_first = SceneStack._stack.size()
	SceneStack.push_scene(test_scene_2)
	assert_eq(SceneStack._stack.size(), stack_size_after_first + 1, "Should add TestScene1 to stack when pushing TestScene2")

func test_multiple_pop_operations_restore_in_order():
	var initial_scene = get_tree().current_scene
	var scene1 = SceneStack.push_scene(test_scene_1)
	var scene2 = SceneStack.push_scene(test_scene_2)
	
	SceneStack.pop_scene(true)
	assert_eq(get_tree().current_scene.name, "TestScene1", "Should restore to TestScene1")
	
	SceneStack.pop_scene(true)
	assert_eq(get_tree().current_scene, initial_scene, "Should restore to initial scene")

func test_clear_cache_empties_stack():
	SceneStack.push_scene(test_scene_1)
	SceneStack.push_scene(test_scene_2)
	SceneStack.clear_cache(false)
	assert_eq(SceneStack._stack.size(), 0, "Should empty the stack")

func test_push_existing_adds_node_to_tree():
	var custom_node = Node2D.new()
	custom_node.name = "CustomNode"
	SceneStack.push_existing(custom_node)
	assert_eq(get_tree().current_scene, custom_node, "Should set custom node as current scene")

func test_push_existing_caches_previous_scene():
	var initial_scene = get_tree().current_scene
	var custom_node = Node2D.new()
	SceneStack.push_existing(custom_node)
	assert_eq(SceneStack._stack.size(), 1, "Should cache previous scene")

func test_cache_pruning_respects_max_limit():
	SceneStack.max_cached_scenes = 2
	
	var initial_scene = get_tree().current_scene
	SceneStack.push_scene(test_scene_1)
	SceneStack.push_scene(test_scene_2)
	
	var third_scene = PackedScene.new()
	var node3 = Node2D.new()
	node3.name = "TestScene3"
	third_scene.pack(node3)
	SceneStack.push_scene(third_scene)
	
	assert_lte(SceneStack._stack.size(), 2, "Stack size should not exceed max_cached_scenes")

func test_pop_scene_with_free_current_false_keeps_scene():
	var scene = SceneStack.push_scene(test_scene_1)
	SceneStack.pop_scene(false)
	assert_not_null(scene, "Scene should not be freed when free_current is false")

func test_scene_state_preservation():
	var initial_scene = get_tree().current_scene
	var test_node = Node2D.new()
	test_node.name = "StateTestNode"
	test_node.position = Vector2(100, 200)
	initial_scene.add_child(test_node)
	
	SceneStack.push_scene(test_scene_1)
	SceneStack.pop_scene(true)
	
	var restored_node = initial_scene.get_node_or_null("StateTestNode")
	assert_not_null(restored_node, "Child node should be preserved")
	assert_eq(restored_node.position, Vector2(100, 200), "Node position should be preserved")
	
	restored_node.queue_free()

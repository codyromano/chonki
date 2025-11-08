extends Marker2D

@export var item_name: PlayerInventory.Item

var item_to_spawn: Node

func _ready() -> void:
	if get_child_count() > 0:
		item_to_spawn = get_child(0)
		item_to_spawn.visible = false
		item_to_spawn.process_mode = Node.PROCESS_MODE_DISABLED
		_disable_collisions(item_to_spawn)
	else:
		push_error("IsaacSecretLetterSpawnPoint: No child node found to spawn")
	
	GlobalSignals.spawn_item_in_location.connect(_on_spawn_item_in_location)

func _disable_collisions(node: Node) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = true
	
	for child in node.get_children():
		_disable_collisions(child)

func _enable_collisions(node: Node) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = false
	
	for child in node.get_children():
		_enable_collisions(child)

func _on_spawn_item_in_location(spawn_item_name: PlayerInventory.Item) -> void:
	print("[DEBUG] Received spawn request for " + str(spawn_item_name))
	print("[DEBUG] This spawn point expects: " + str(item_name))
	print("[DEBUG] spawn_item_name == item_name: " + str(spawn_item_name == item_name))
	print("[DEBUG] item_to_spawn exists: " + str(item_to_spawn != null))
	
	if spawn_item_name == item_name and item_to_spawn:
		print("[DEBUG] Spawning secret letter L!")
		item_to_spawn.visible = true
		item_to_spawn.process_mode = Node.PROCESS_MODE_INHERIT
		_enable_collisions(item_to_spawn)

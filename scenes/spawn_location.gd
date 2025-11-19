extends Marker2D

# The inventory item type that triggers this spawn location
@export var item_name: PlayerInventory.Item

# When true, item spawns immediately without waiting for signal
@export var auto_spawn: bool = false

var item_to_spawn: Node2D

func _ready() -> void:
	# Get the first child as the item to spawn
	if get_child_count() > 0:
		item_to_spawn = get_child(0)
		
		# If auto_spawn is true, show immediately
		if auto_spawn:
			item_to_spawn.visible = true
			item_to_spawn.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			# Otherwise, make it invisible and disable collision
			item_to_spawn.visible = false
			item_to_spawn.process_mode = Node.PROCESS_MODE_DISABLED
			# Disable collision for any CollisionShape2D or Area2D children
			_disable_collisions(item_to_spawn)
	else:
		push_error("spawn_location: No child node found to spawn")
	
	# Connect to the global spawn signal
	GlobalSignals.spawn_item_in_location.connect(_on_spawn_item_in_location)

func _disable_collisions(node: Node) -> void:
	# Disable collision shapes
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = true
	
	# Recursively disable collisions in children
	for child in node.get_children():
		_disable_collisions(child)

func _enable_collisions(node: Node) -> void:
	# Enable collision shapes
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = false
	
	# Recursively enable collisions in children
	for child in node.get_children():
		_enable_collisions(child)

func _on_spawn_item_in_location(spawn_item_name: PlayerInventory.Item) -> void:
	if spawn_item_name == item_name and item_to_spawn:
		item_to_spawn.visible = true
		item_to_spawn.process_mode = Node.PROCESS_MODE_INHERIT
		
		_enable_collisions(item_to_spawn)

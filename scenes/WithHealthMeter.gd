@tool
extends Node2D
class_name WithHealthMeter

@onready var heart_texture = preload("res://assets/collectibles/menu-icons/heart.png")

@export var total_hearts: int = 3:
	set(value):
		total_hearts = value
		_update_hearts()

var hearts_container: Node2D
var child_node: Node2D

func _ready():
	# Create container for hearts
	hearts_container = Node2D.new()
	hearts_container.name = "HeartsContainer"
	add_child(hearts_container)
	
	# Connect signals to detect child changes
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	
	# Find the child Node2D
	_find_child_node()
	
	# Initial heart setup
	_update_hearts()

func _find_child_node():
	# Look for the first Node2D child that isn't our hearts container
	for child in get_children():
		if child is Node2D and child != hearts_container:
			child_node = child
			print("found child: ", child)
			break
			
func _process(_delta) -> void:
	_update_hearts()

func _update_hearts():
	if not hearts_container:
		print("no heart container")
		return
	
	# Clear existing hearts
	for heart in hearts_container.get_children():
		heart.queue_free()
	
	if total_hearts <= 0:
		return
	
	# Calculate positioning
	var heart_size = Vector2(75, 75)
	var heart_spacing = 100  # Gap between hearts
	var total_width = (total_hearts * heart_size.x) + ((total_hearts - 1) * heart_spacing)
	var start_x = -total_width / 2.0
	
	# Get child position for vertical offset
	var child_pos = Vector2.ZERO
	if child_node:
		child_pos = child_node.global_position
		print("child position: ", child_pos)
	else:
		print("no child position")
	
	var heart_spacing_base = 200

	
	# Create hearts
	for i in range(total_hearts):
		var heart = _create_heart()
		hearts_container.add_child(heart)
		
		var spacing = 400 * heart.scale.x
		
		# Position heart
		# var x_pos = start_x + (i * (heart_size.x + heart_spacing)) + (heart_size.x / 2.0)
		var x_pos = child_node.global_position.x + (i * spacing) - 100
		var y_pos = child_pos.y - heart_size.y - 20  # 20px above child
		
		# print("position heart " + str(i) + " at " + str(x_pos) + "," + str(y_pos))
		heart.global_position = Vector2(x_pos, y_pos)

func _create_heart() -> Sprite2D:
	var heart_node = Sprite2D.new()
	
	heart_node.scale = Vector2(0.25, 0.25)
	heart_node.texture = heart_texture
	heart_node.position = Vector2(-37.5, -37.5)
	
	return heart_node

# Signal handlers for child changes
func _on_child_entered_tree(node):
	if node != hearts_container and node is Node2D:
		print("on child entered tree")
		_find_child_node()
		_update_hearts()

func _on_child_exiting_tree(node):
	if node == child_node:
		print("on child exiting tree")
		child_node = null
		_update_hearts()

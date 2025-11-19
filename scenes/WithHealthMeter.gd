@tool
extends Node2D
class_name WithHealthMeter

@onready var heart_texture = preload("res://assets/collectibles/menu-icons/heart.png")
var child_node: Node2D

@export var total_hearts: int = 3:
	set(value):
		total_hearts = value
		_update_hearts()

var hearts_container: Node2D


func _ready():
	child_node = get_children()[0]
	if child_node == null:
		push_error('WithHealthMeter expects single Node2D child')
	
	# Create container for hearts
	hearts_container = Node2D.new()
	hearts_container.name = "HeartsContainer"
	add_child(hearts_container)
	
	# Initial heart setup
	_update_hearts()
			
func _process(_delta) -> void:
	_update_hearts()

func _update_hearts():
	if not hearts_container:
		return
	
	# Clear existing hearts
	for heart in hearts_container.get_children():
		heart.queue_free()
	
	if total_hearts <= 0:
		return
	
	# Calculate positioning
	var heart_size = Vector2(75, 75)
	var heart_spacing = 200  # Gap between hearts
	var total_width = (total_hearts * heart_size.x) + ((total_hearts - 1) * heart_spacing)
	var start_x = -total_width / 2.0
	
	# Get child position for vertical offset
	var child_pos = Vector2.ZERO
	if child_node:
		child_pos = child_node.global_position
	
	var heart_spacing_base = 200

	
	# Create hearts
	for i in range(total_hearts):
		var heart = _create_heart()
		hearts_container.add_child(heart)
		
		var spacing = 400 * heart.scale.x
		
		# Position heart
		var x_pos = child_node.global_position.x + (i * spacing) - spacing * 1
		var y_pos = child_pos.y
		
		heart.global_position = Vector2(x_pos, y_pos)

func _create_heart() -> Sprite2D:
	var heart_node = Sprite2D.new()
	
	heart_node.scale = Vector2(0.25, 0.25)
	heart_node.texture = heart_texture
	heart_node.position = Vector2(-37.5, -37.5)
	
	return heart_node

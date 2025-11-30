@tool
extends Sprite2D

@export var leg_height: float = 40

func extend_polygon_bottom(polygon_node: Polygon2D, extra_height: float) -> PackedVector2Array:
	var points = polygon_node.polygon.duplicate()
	
	if points.size() != 4:
		push_error("This function only supports 4-point rectangular polygons.")
	
	var top_left = points[0]
	var top_right = points[1]
	var bottom_right = points[2]
	var bottom_left = points[3]
	
	# Extend the bottom two points downward
	bottom_left.y += extra_height
	bottom_right.y += extra_height
	
	# Update the polygon
	polygon_node.polygon = PackedVector2Array([
		top_left,
		top_right,
		bottom_right,
		bottom_left,
	])
	
	return polygon_node.polygon

func _ready() -> void:
	var new_leg_position = extend_polygon_bottom($LeftLegRepeatable, leg_height)
	extend_polygon_bottom($RightLegRepeatable, leg_height)
	
	# Convert from Polygon2D's local space to parent's local space
	var polygon_transform = $LeftLegRepeatable.transform
	var bottom_point_in_parent_space = polygon_transform * new_leg_position[2]
	
	$LegEndLeft.position.y = bottom_point_in_parent_space.y
	$LegEndRight.position.y = bottom_point_in_parent_space.y
	
	

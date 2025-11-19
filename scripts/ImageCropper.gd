extends Node
class_name ImageCropper

## Utility class to crop images in TextureRect nodes without modifying the original image files
## This uses a custom shader to crop pixels from the bottom of images

@export var crop_bottom_pixels: int = 50

# Custom shader code for cropping
static var crop_shader_code = """
shader_type canvas_item;

uniform float crop_bottom : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	// Calculate the adjusted UV coordinates
	// We need to scale the UV.y to exclude the bottom portion
	vec2 adjusted_uv = UV;
	adjusted_uv.y = UV.y * (1.0 - crop_bottom);
	
	// Sample the texture with the adjusted coordinates
	COLOR = texture(TEXTURE, adjusted_uv);
	
	// Make cropped area transparent
	if (UV.y > (1.0 - crop_bottom)) {
		COLOR.a = 0.0;
	}
}
"""

## Apply cropping to a single TextureRect
static func apply_crop_to_texture_rect(texture_rect: TextureRect, crop_pixels: int = 50):
	if not texture_rect or not texture_rect.texture:
		push_error("ImageCropper: Invalid TextureRect or missing texture")
		return
	
	# Get the texture dimensions
	var texture_size = texture_rect.texture.get_size()
	var crop_ratio = float(crop_pixels) / texture_size.y
	
	# Create the shader material
	var shader = Shader.new()
	shader.code = crop_shader_code
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("crop_bottom", crop_ratio)
	
	texture_rect.material = shader_material

static func apply_crop_to_all_children(parent_node: Node, crop_pixels: int = 50):
	var texture_rects = []
	_find_texture_rects_recursive(parent_node, texture_rects)
	
	for texture_rect in texture_rects:
		apply_crop_to_texture_rect(texture_rect, crop_pixels)

## Recursively find all TextureRect nodes
static func _find_texture_rects_recursive(node: Node, texture_rects: Array):
	if node is TextureRect:
		texture_rects.append(node)
	
	for child in node.get_children():
		_find_texture_rects_recursive(child, texture_rects)

static func remove_crop_from_texture_rect(texture_rect: TextureRect):
	if texture_rect:
		texture_rect.material = null

static func remove_crop_from_all_children(parent_node: Node):
	var texture_rects = []
	_find_texture_rects_recursive(parent_node, texture_rects)
	
	for texture_rect in texture_rects:
		remove_crop_from_texture_rect(texture_rect)
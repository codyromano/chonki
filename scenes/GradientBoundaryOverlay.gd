extends CanvasLayer

@export var player: Node2D
@export var left_boundary_x: float = 6851.0
@export var right_boundary_x: float = 22525.0
@export var gradient_width: float = 800.0

var camera: Camera2D
var left_overlay: ColorRect
var right_overlay: ColorRect
var left_shader_material: ShaderMaterial
var right_shader_material: ShaderMaterial

func _ready():
	layer = 10
	
	if not player:
		var scene_root = get_tree().current_scene
		player = scene_root.get_node_or_null("Characters/BonusChonki")
	
	if player:
		camera = player.find_child("Camera2D", true, false)
		if not camera:
			push_error("GradientBoundaryOverlay: Camera2D not found in player node")
	else:
		push_error("GradientBoundaryOverlay: Player node not assigned")
	
	_create_overlays()
	GlobalSignals.connect("camera_position_changed", _on_camera_position_changed)
	
	if camera:
		_on_camera_position_changed(camera.global_position)

func _create_overlays():
	left_overlay = ColorRect.new()
	left_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(left_overlay)
	
	right_overlay = ColorRect.new()
	right_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(right_overlay)
	
	_create_shaders()

func _create_shaders():
	var left_shader_code = """
shader_type canvas_item;

uniform float boundary_screen_x = 0.0;
uniform float gradient_width = 800.0;
uniform vec2 viewport_size = vec2(1920.0, 1080.0);

void fragment() {
	float screen_x = UV.x * viewport_size.x;
	
	if (screen_x < boundary_screen_x) {
		COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	} else if (screen_x < boundary_screen_x + gradient_width) {
		float distance_from_boundary = screen_x - boundary_screen_x;
		float alpha = 1.0 - (distance_from_boundary / gradient_width);
		COLOR = vec4(1.0, 1.0, 1.0, alpha);
	} else {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}
"""
	
	var right_shader_code = """
shader_type canvas_item;

uniform float boundary_screen_x = 0.0;
uniform float gradient_width = 800.0;
uniform vec2 viewport_size = vec2(1920.0, 1080.0);

void fragment() {
	float screen_x = UV.x * viewport_size.x;
	
	if (screen_x > boundary_screen_x) {
		COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	} else if (screen_x > boundary_screen_x - gradient_width) {
		float distance_from_boundary = boundary_screen_x - screen_x;
		float alpha = 1.0 - (distance_from_boundary / gradient_width);
		COLOR = vec4(1.0, 1.0, 1.0, alpha);
	} else {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}
"""
	
	var left_shader = Shader.new()
	left_shader.code = left_shader_code
	left_shader_material = ShaderMaterial.new()
	left_shader_material.shader = left_shader
	left_overlay.material = left_shader_material
	
	var right_shader = Shader.new()
	right_shader.code = right_shader_code
	right_shader_material = ShaderMaterial.new()
	right_shader_material.shader = right_shader
	right_overlay.material = right_shader_material

func _on_camera_position_changed(camera_pos: Vector2):
	if not camera:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_zoom = camera.zoom
	
	var left_boundary_screen_x = _world_to_screen_x(left_boundary_x, camera_pos.x, viewport_size.x, camera_zoom.x) - 800.0
	var right_boundary_screen_x = _world_to_screen_x(right_boundary_x, camera_pos.x, viewport_size.x, camera_zoom.x) + 800.0
	
	left_shader_material.set_shader_parameter("boundary_screen_x", left_boundary_screen_x)
	left_shader_material.set_shader_parameter("gradient_width", gradient_width)
	left_shader_material.set_shader_parameter("viewport_size", viewport_size)
	
	right_shader_material.set_shader_parameter("boundary_screen_x", right_boundary_screen_x)
	right_shader_material.set_shader_parameter("gradient_width", gradient_width)
	right_shader_material.set_shader_parameter("viewport_size", viewport_size)

func _world_to_screen_x(world_x: float, camera_x: float, viewport_width: float, camera_zoom_x: float) -> float:
	var offset_from_camera = world_x - camera_x
	var screen_offset = offset_from_camera * camera_zoom_x
	var screen_x = (viewport_width / 2.0) + screen_offset
	return screen_x

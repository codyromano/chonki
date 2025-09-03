extends TextureRect

@export var scroll_speed: Vector2 = Vector2(0.05, 0.05)  # UV scroll speed per second
@export var auto_start: bool = true

var shader_material: ShaderMaterial
var time_passed: float = 0.0

func _ready():
	setup_scrolling_shader()
	if auto_start:
		start_scrolling()

func setup_scrolling_shader():
	# Create a shader for UV scrolling
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.1);
uniform float time_offset = 0.0;

void fragment() {
	vec2 scrolled_uv = UV + scroll_speed * time_offset;
	COLOR = texture(TEXTURE, scrolled_uv);
}
"""
	
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("scroll_speed", scroll_speed)
	
	material = shader_material

func start_scrolling():
	set_process(true)

func stop_scrolling():
	set_process(false)

func _process(delta):
	time_passed += delta
	if shader_material:
		shader_material.set_shader_parameter("time_offset", time_passed)

func set_scroll_speed(new_speed: Vector2):
	scroll_speed = new_speed
	if shader_material:
		shader_material.set_shader_parameter("scroll_speed", scroll_speed)

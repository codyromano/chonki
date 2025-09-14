extends Control
class_name SecretLetter

## A 3D rotating gold letter that can be used in 2D scenes
## Uses a SubViewport to render 3D content for use in 2D games

@export var letter: String = "A" : set = set_letter
@export var rotation_speed: float = 90.0  # degrees per second
@export var font_size: int = 240 : set = set_font_size
@export var letter_depth: float = 1.0 : set = set_letter_depth

@onready var subviewport: SubViewport = $SubViewport
@onready var letter_mesh: MeshInstance3D = $SubViewport/LetterMesh
@onready var text_mesh: TextMesh = $SubViewport/LetterMesh.mesh

@onready var font_family: Font = preload("res://fonts/Sniglet-Regular.ttf")

func _ready():
	# Ensure the letter is set properly when the scene loads
	if text_mesh:
		text_mesh.font = font_family
		set_letter(letter)
		set_font_size(font_size)
		set_letter_depth(letter_depth)

func _process(delta):
	# Continuously rotate the letter around the Y-axis
	if letter_mesh:
		letter_mesh.rotation_degrees.y += rotation_speed * delta

func set_letter(new_letter: String):
	letter = new_letter.to_upper()  # Convert to uppercase for consistency
	
	if text_mesh:
		text_mesh.text = letter
	else:
		# If called before _ready, store the value for later
		call_deferred("_update_letter_text")

func set_font_size(new_size: int):
	font_size = new_size
	
	if text_mesh:
		text_mesh.font_size = font_size
	else:
		call_deferred("_update_font_size")

func set_letter_depth(new_depth: float):
	letter_depth = new_depth
	
	if text_mesh:
		text_mesh.depth = letter_depth
	else:
		call_deferred("_update_letter_depth")

func _update_letter_text():
	if text_mesh:
		text_mesh.text = letter

func _update_font_size():
	if text_mesh:
		text_mesh.font_size = font_size

func _update_letter_depth():
	if text_mesh:
		text_mesh.depth = letter_depth

## Set the size of the viewport and control
func set_viewport_size(viewport_size: Vector2i):
	if subviewport:
		subviewport.size = viewport_size
	custom_minimum_size = Vector2(viewport_size)

## Get the current letter rotation in degrees
func get_letter_rotation_degrees() -> float:
	if letter_mesh:
		return letter_mesh.rotation_degrees.y
	return 0.0

## Set the rotation speed (degrees per second)
func set_rotation_speed(speed: float):
	rotation_speed = speed

## Pause/resume rotation
func set_rotation_enabled(enabled: bool):
	set_process(enabled)

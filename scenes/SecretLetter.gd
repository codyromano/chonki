extends Control

## A 3D rotating gold letter that can be used in 2D scenes
## Uses a SubViewport to render 3D content for use in 2D games

@export var letter: String = "A" : set = set_letter
@export var rotation_speed: float = 90.0  # degrees per second
@export var font_size: int = 240 : set = set_font_size
@export var letter_depth: float = 1.0 : set = set_letter_depth

@onready var subviewport: SubViewport = $SubViewport
@onready var letter_mesh: MeshInstance3D = $SubViewport/LetterMesh
# @onready var text_mesh: TextMesh = $SubViewport/LetterMesh.mesh
@onready var area_2d: Area2D = $Area2D
@onready var magic_dust_particles: CPUParticles2D = $MagicDustParticles

@onready var font_family: Font = preload("res://fonts/Sniglet-Regular.ttf")

var is_mesh_text_set: bool = false


# Audio player - made optional to prevent errors if node doesn't exist
var audio_player: AudioStreamPlayer

var original_rotation_speed: float
var is_collected: bool = false
var tween: Tween

var text_mesh: TextMesh

func _ready():
	# Create a unique TextMesh resource for this instance
	text_mesh = TextMesh.new()
	text_mesh.font = font_family
	text_mesh.font_size = font_size
	text_mesh.depth = letter_depth
	
	# Assign the unique TextMesh to the MeshInstance3D
	if letter_mesh:
		letter_mesh.mesh = text_mesh
	
	# Store the original rotation speed
	original_rotation_speed = rotation_speed
	
	# Safely get the audio player if it exists
	audio_player = get_node_or_null("AudioStreamPlayer")
	
	print("_ready() received letter ", letter)
	
	# Start with particles disabled - they'll only appear after collision
	if magic_dust_particles:
		magic_dust_particles.emitting = false
	
	# Connect the collision detection
	if area_2d:
		area_2d.body_entered.connect(_on_body_entered)
	
	# Ensure the letter is set properly when the scene loads
	if text_mesh:
		set_letter(letter)

func _process(delta):
	# Continuously rotate the letter around the Y-axis
	if letter_mesh:
		letter_mesh.rotation_degrees.y += rotation_speed * delta

func set_letter(new_letter: String):
	letter = new_letter.to_upper()  # Convert to uppercase for consistency
	
	if text_mesh:
		print("setting letter to ", letter, " on text mesh RID ", text_mesh.get_rid())
		if !is_mesh_text_set:
			text_mesh.text = letter
			is_mesh_text_set = true
	#else:
		# If called before _ready, store the value for later
		#call_deferred("_update_letter_text")

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
	pass
	#if text_mesh:
		#print("updating letter to ", letter, " on text mesh RID ", text_mesh.get_rid())
		#text_mesh.text = letter

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

## Called when Chonki collides with the SecretLetter
func _on_body_entered(body: Node2D):
	# Check if it's Chonki (CharacterBody2D)
	if body is CharacterBody2D and not is_collected:
		is_collected = true
		_start_collection_sequence()

## Start the collection animation sequence
func _start_collection_sequence():
	# Emit global signal that a secret letter was collected
	GlobalSignals.secret_letter_collected.emit(letter)
	
	# Play the secret letter collection sound
	if audio_player:
		audio_player.play()
	
	# Step 1: Start particle emission and increase rotation speed by 10x
	if magic_dust_particles:
		magic_dust_particles.emitting = true
		# Intensify particle effects during collection
		magic_dust_particles.amount = 60  # Double the particles
		magic_dust_particles.initial_velocity_min = 40.0
		magic_dust_particles.initial_velocity_max = 80.0
		magic_dust_particles.orbit_velocity_min = 0.5
		magic_dust_particles.orbit_velocity_max = 1.0
	
	rotation_speed = original_rotation_speed * 10.0
	
	# Step 2: After 2 seconds, start shrinking
	await get_tree().create_timer(2.0).timeout
	_start_shrinking()

## Shrink the letter to 1/10th size over 0.5 seconds
func _start_shrinking():
	# Stop particle emission during shrinking
	if magic_dust_particles:
		magic_dust_particles.emitting = false
	
	tween = create_tween()
	var target_scale = scale * 0.1
	
	# Shrink over 0.5 seconds
	tween.tween_property(self, "scale", target_scale, 0.5)
	
	# When shrinking is complete, queue free
	tween.tween_callback(queue_free)

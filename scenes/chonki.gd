extends Node2D

@onready var body         : CharacterBody2D     = $CharacterBody2D
@onready var sprite       : AnimatedSprite2D     = $CharacterBody2D/AnimatedSprite2D
@onready var run_sound    : AudioStreamPlayer2D  = $CharacterBody2D/AudioRun
@onready var rest_sound   : AudioStreamPlayer2D  = $CharacterBody2D/RestRun
@onready var ram_sound    : AudioStreamPlayer2D  = $CharacterBody2D/AudioRam
@onready var push_sound   : AudioStreamPlayer2D  = $CharacterBody2D/AudioPush
@onready var jump_sound   : AudioStreamPlayer2D  = $CharacterBody2D/AudioJump

enum ChonkiState { IDLE, RUN, ATTACK }

var state : ChonkiState = ChonkiState.IDLE

# Make the dog sleep initially
var last_action_time : int = Time.get_unix_time_from_system() - 60

var velocity: Vector2 = Vector2.ZERO
const SPEED: float = 2000.0
const JUMP_FORCE: float = -2500.0
const GRAVITY: float = 3000.0

func _ready() -> void:
	sprite.play("sleep")

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	update_sprite()
	play_sound_effects()

func handle_movement(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_up") and body.is_on_floor():
		# jump_sound.play()
		velocity.y = JUMP_FORCE

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	body.velocity = velocity
	body.move_and_slide()

func play_once(player: AudioStreamPlayer2D) -> void:
	if not player.playing:
		player.play()

func play_sound_effects() -> void:
	var anim = sprite.animation

	
	if Input.is_action_just_pressed("ui_up"):
		play_once(jump_sound)

	match anim:
		"ram":
			rest_sound.stop()
			play_once(ram_sound)

		"push":
			rest_sound.stop()
			play_once(push_sound)
			# ram_sound.stop()
			# run_sound.stop()
			# rest_sound.stop()

		"run":
			rest_sound.stop()
			# run_sound.play()
			pass
			# ram_sound.stop()
			# push_sound.stop()
			# rest_sound.stop()

		"sleep":
			play_once(rest_sound)
			
		"jump":
			rest_sound.stop()
			if $CharacterBody2D.is_on_floor_only():
				run_sound.stop()
				play_once(jump_sound)

		"idle":
			rest_sound.stop()
			run_sound.stop()
			# ram_sound.stop()
			# push_sound.stop()
			# rest_sound.stop()
			# run_sound.stop()

func play_on_ground(player: AudioStreamPlayer2D) -> void:
	if $CharacterBody2D.is_on_floor():
		player.play()

func update_sprite() -> void:
	var is_taking_action: bool = false
	var current_animation = sprite.animation

	if current_animation in ["ram", "push"] and sprite.is_playing():
		return

	if Input.is_action_just_pressed("push"):
		sprite.play("push")
		is_taking_action = true
	elif Input.is_action_just_pressed("ram"):
		sprite.play("ram")
		is_taking_action = true
	elif velocity.x != 0:
		sprite.play("run")
		if !run_sound.playing:
			run_sound.play()
		is_taking_action = true

	if not body.is_on_floor():
		sprite.play("jump")
		run_sound.stop()

	if Input.is_action_just_pressed("ui_left"):
		#play_on_ground(run_sound)
		sprite.flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
		# play_on_ground(run_sound)
		sprite.flip_h = false

	var secs_since_action = Time.get_unix_time_from_system() - last_action_time

	if is_taking_action:
		last_action_time = Time.get_unix_time_from_system()
	elif secs_since_action >= 15:
		sprite.play("sleep")
	elif secs_since_action >= 5:
		sprite.play("rest")
	else:
		sprite.play("idle")

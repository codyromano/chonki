extends Node2D

@onready var body         : CharacterBody2D     = $CharacterBody2D
@onready var sprite       : AnimatedSprite2D     = $CharacterBody2D/AnimatedSprite2D
@onready var run_sound    : AudioStreamPlayer2D  = $AudioRun
@onready var rest_sound   : AudioStreamPlayer2D  = $RestRun
@onready var ram_sound    : AudioStreamPlayer2D  = $AudioRam
@onready var push_sound   : AudioStreamPlayer2D  = $AudioPush

enum ChonkiState { IDLE, RUN, ATTACK }

var state : ChonkiState = ChonkiState.IDLE
var last_action_time : float = Time.get_unix_time_from_system()

var velocity: Vector2 = Vector2.ZERO
const SPEED: float = 2000.0
const JUMP_FORCE: float = -2500.0
const GRAVITY: float = 3000.0

		
func _physics_process(delta: float) -> void:	
	handle_movement(delta)
	update_sprite()

func handle_movement(delta: float) -> void:
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_up") and body.is_on_floor():
		$AudioJump.play()
		velocity.y = JUMP_FORCE

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	body.velocity = velocity
	body.move_and_slide()

func play_once(player: AudioStreamPlayer2D) -> void:
	if not player.playing:
		player.play()

func play_sound_effect() -> void:
	var anim = sprite.animation
	var is_running = Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	var secs_since_action = Time.get_unix_time_from_system() - last_action_time

	if anim == "ram":
		play_once(ram_sound)
	elif anim == "push":
		play_once(push_sound)

	# Stop both sounds during attack or jump
	if anim in ["ram", "push", "jump"]:
		run_sound.stop()
		rest_sound.stop()
	elif is_running:
		# Only play run sound if NOT jumping, ramming, or pushing
		if not run_sound.playing:
			run_sound.play()
		rest_sound.stop()
	elif anim == "sleep":
		run_sound.stop()
		if not rest_sound.playing:
			rest_sound.play()
	else:
		run_sound.stop()
		rest_sound.stop()

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
		is_taking_action = true

	if not body.is_on_floor():
		sprite.play("jump")
		is_taking_action = true

	if Input.is_action_just_pressed("ui_left"):
		sprite.flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
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

	play_sound_effect()

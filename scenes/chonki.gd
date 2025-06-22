extends Node2D
@onready var body         : CharacterBody2D    = $ChonkiCharacter
@onready var sprite       : AnimatedSprite2D     = $ChonkiCharacter/AnimatedSprite2D
@onready var run_sound    : AudioStreamPlayer2D  = $ChonkiCharacter/AudioRun
@onready var rest_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/RestRun
@onready var ram_sound    : AudioStreamPlayer2D  = $ChonkiCharacter/AudioRam
@onready var push_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/AudioPush
@onready var jump_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/AudioJump
@onready var chill_bark   : AudioStreamPlayer2D  = $ChonkiCharacter/ChillBark

enum ChonkiState { IDLE, RUN, ATTACK }

var state : ChonkiState = ChonkiState.IDLE
var last_action_time : int = Time.get_unix_time_from_system() - 60
var velocity: Vector2 = Vector2.ZERO
var chonki_hit = false
var original_collision_mask: int

var hit_time: int

const SPEED: float = 3500.0
const JUMP_FORCE: float = -8000.0   # 3x faster: -4000 × 3 = -12000
const GRAVITY: float = 20000.0       # 9x stronger: 8000 × 9 = 72000
const HIT_RECOVERY_TIME: float = 1

var is_game_win = false 

func _ready() -> void:
	sprite.play("sleep")
	GlobalSignals.connect("player_hit", on_player_hit)
	GlobalSignals.connect("win_game", on_win_game)
	
func on_win_game() -> void:
	is_game_win = true
	
func on_player_hit() -> void:
	GlobalSignals.heart_lost.emit()
	$ChonkiCharacter/AudioOuch.play()
	hit_time = Time.get_unix_time_from_system()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	update_sprite()
	play_sound_effects()
	body.move_and_slide()

func handle_movement(delta: float) -> void:
	# Don't move Chonki after he reunites with his owner
	if is_game_win:
		body.velocity = Vector2(0, 0)
		return
	
	var direction: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	var current_time = Time.get_unix_time_from_system()
	if hit_time != null && current_time - hit_time <= HIT_RECOVERY_TIME:
		velocity.x = 2000 if sprite.flip_h else -2000
		velocity.y = 1000
		body.velocity = velocity
		return
	elif hit_time != null && current_time - hit_time >= HIT_RECOVERY_TIME && original_collision_mask > 0:
		pass
		# body.collision_mask = original_collision_mask
		
	if Input.is_action_just_pressed("push") or Input.is_action_just_pressed("ram"):
		if body.is_on_floor():
			velocity.y = -1000  # optional: slight hop
	else:
		velocity.x = direction * SPEED
	# Apply gravity
	velocity.y += GRAVITY * delta
	# Jump
	if Input.is_action_just_pressed("ui_up") and body.is_on_floor():
		velocity.y = JUMP_FORCE
	body.velocity = velocity

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
			await get_tree().create_timer(0.5).timeout
			play_once(ram_sound)
			play_once(chill_bark)
		"push":
			ram_sound.stop()
			# push_sound.stop()
			rest_sound.stop()
			await get_tree().create_timer(0.5).timeout
			play_once(push_sound)
			play_once(chill_bark)
		"run":
			rest_sound.stop()
		"sleep":
			play_once(rest_sound)
		"jump":
			rest_sound.stop()
			if body.is_on_floor_only():
				run_sound.stop()
				play_once(jump_sound)
		"idle":
			rest_sound.stop()
			run_sound.stop()

func play_on_ground(player: AudioStreamPlayer2D) -> void:
	if body.is_on_floor():
		player.play()

func get_attack_sprite():
	if sprite.animation in ["ram", "push"] && sprite.is_playing():
		return sprite.animation
	
	if Input.is_action_just_pressed("push"):
		return "push"
	elif Input.is_action_just_pressed("ram"):
		return "ram"

	return null

func get_player_injured_sprite():
	var current_time: int = Time.get_unix_time_from_system()
	return "ouch" if hit_time != null && current_time - hit_time <= HIT_RECOVERY_TIME else null

func get_run_sprite():
	if velocity.x != 0:
		if not run_sound.playing:
			run_sound.play()
		return "run"
	return null

func get_jump_sprite():
	if not body.is_on_floor():
		run_sound.stop()
		return "jump"
	return null

func get_sleep_sprite():
	var secs_since_action = Time.get_unix_time_from_system() - last_action_time
	if secs_since_action >= 15:
		return "sleep"
	return null

func get_rest_sprite():
	var secs_since_action = Time.get_unix_time_from_system() - last_action_time
	if secs_since_action >= 5:
		return "rest"
	return null

func get_idle_sprite():
	return "idle"
	
func get_win_game_sprite():
	return "rest" if is_game_win else null

func handle_sprite_flip():
	if is_game_win:
		sprite.flip_h = false
	elif Input.is_action_just_pressed("ui_left"):
		sprite.flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
		sprite.flip_h = false
	
func update_sprite() -> void:
	# Different types of sprites for the player character,
	# sorted by priority. Each returns a string or null
	var possible_next_sprites = [
		get_win_game_sprite(),
		get_player_injured_sprite(),
		get_attack_sprite(),
		get_jump_sprite(),
		get_run_sprite(),
		get_sleep_sprite(),
		get_rest_sprite(),
		get_idle_sprite()
	]
	
	var is_taking_action: bool = false
	
	# Track the last action item forthe purpose of playing a
	# a rest, the sleep, animation after a period of inactivity
	if velocity.x != 0 or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		last_action_time = Time.get_unix_time_from_system()
	
	# Find the first valid sprite and play it
	for next_sprite in possible_next_sprites:
		if next_sprite != null:
			sprite.play(next_sprite)
			handle_sprite_flip()
			return

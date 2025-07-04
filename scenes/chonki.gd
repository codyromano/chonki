extends Node2D

@onready var body         : CharacterBody2D    = $ChonkiCharacter
@onready var sprite       : AnimatedSprite2D   = $ChonkiCharacter/AnimatedSprite2D
@onready var run_sound    : AudioStreamPlayer2D  = $ChonkiCharacter/AudioRun
@onready var rest_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/RestRun
@onready var ram_sound    : AudioStreamPlayer2D  = $ChonkiCharacter/AudioRam
@onready var push_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/AudioPush
@onready var jump_sound   : AudioStreamPlayer2D  = $ChonkiCharacter/AudioJump
@onready var chill_bark   : AudioStreamPlayer2D  = $ChonkiCharacter/ChillBark

@export var heart_texture: Texture2D

enum ChonkiState { IDLE, RUN, ATTACK }

var state : ChonkiState = ChonkiState.IDLE
var last_action_time : float = Time.get_unix_time_from_system() - 60.0
var velocity: Vector2 = Vector2.ZERO
var chonki_hit = false
var original_collision_mask: int

var hit_time: float

const SPEED: float = 3500.0
const JUMP_FORCE: float = -8000.0
const GRAVITY: float = 20000.0
const HIT_RECOVERY_TIME: float = 1
var is_game_win = false 

var fade_rect: ColorRect
@onready var hud = get_tree().get_first_node_in_group("HUDControl")
var is_game_over = false


# Signal to indicate Chonki has landed and hearts have spawned
signal chonki_landed_and_hearts_spawned

func _ready() -> void:
	sprite.play("sleep")
	GlobalSignals.connect("player_hit", on_player_hit)
	GlobalSignals.connect("win_game", on_win_game)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)
	# Always reset GameState at the start of the level
	GameState.reset()
	# Cache and set total_stars for this level by scene path, using CollectibleStar group
	var level_path = get_tree().current_scene.scene_file_path
	var total_stars = GameState.get_total_stars_for_level(level_path)
	if total_stars == 0:
		total_stars = get_tree().get_nodes_in_group("CollectibleStar").size()
		GameState.set_total_stars_for_level(level_path, total_stars)
	else:
		GameState.total_stars = total_stars
	# Create a fullscreen ColorRect for fade effect
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1000
	add_child(fade_rect)
	fade_rect.visible = false

func on_win_game() -> void:
	is_game_win = true
	# Wait for Chonki to land on the floor before spawning hearts
	await wait_for_chonki_to_land()
	spawn_floating_hearts()
	emit_signal("chonki_landed_and_hearts_spawned")
	# Start fade out and scene transition after 5 seconds using the autoload
	FadeTransition.fade_out_and_change_scene("res://scenes/level_result.tscn", 5.0, 3.0)

func wait_for_chonki_to_land() -> void:
	while not body.is_on_floor():
		await get_tree().process_frame

func spawn_floating_hearts() -> void:
	var frame_texture = sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	)
	var size: Vector2 = frame_texture.get_size() * sprite.scale
	
	for i in range(25):
		var heart = Sprite2D.new()
		heart.texture = heart_texture
		heart.scale = Vector2(0.5, 0.5)
		
		heart.global_position = sprite.global_position + Vector2(-(size.x / 2), size.y / 2)
		heart.modulate.a = 0.0
		add_child(heart)

		var direction = Vector2(randf() * 2.0 - 1.0, randf() * -1.5).normalized()
		# var distance = randf() * 200 + 100
		var distance = randf() * 2000 + 100
		var end_pos = heart.global_position + direction * distance

		var tween = create_tween()
		tween.tween_property(heart, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(heart, "global_position", end_pos, 6.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(heart, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_callback(Callable(heart, "queue_free"))

func on_player_hit() -> void:
	GlobalSignals.heart_lost.emit()
	$ChonkiCharacter/AudioOuch.play()
	hit_time = Time.get_unix_time_from_system()

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	update_sprite()
	play_sound_effects()
	body.move_and_slide()
	
func get_platform_velocity() -> Vector2:
	var platform_velocity = Vector2()
	
	if body.is_on_floor():
		var collision = body.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			# Check if standing on Volleyball
			if collider and collider.get_script() and collider.get_script().resource_path == "res://scenes/Volleyball.gd":
				if "get_platform_velocity" in collider:
					var v = collider.get_platform_velocity()
					# print("Chonki is standing on a Volleyball! Volleyball x velocity: %f" % v.x)
					platform_velocity = v
				#else:
					platform_velocity = Vector2.ZERO
			else:
				platform_velocity = Vector2.ZERO
		else:
			platform_velocity = Vector2.ZERO
	
	return platform_velocity

func handle_movement(delta: float) -> void:
	var platform_velocity = get_platform_velocity()

	var direction: float = 0.0
	if not is_game_win:
		direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	var current_time = Time.get_unix_time_from_system()

	if hit_time != null && current_time - hit_time <= HIT_RECOVERY_TIME:
		velocity.x = 2000 if sprite.flip_h else -2000
		velocity.y = 1000
		body.velocity = velocity
		return
	elif hit_time != null && current_time - hit_time >= HIT_RECOVERY_TIME && original_collision_mask > 0:
		pass

	# Handle horizontal movement and special actions
	if not is_game_win and (Input.is_action_just_pressed("push") or Input.is_action_just_pressed("ram")):
		if body.is_on_floor():
			velocity.y = -1000
	else:
		# Offset Chonki's velocity by the platform's velocity to keep Chonki on moving platforms
		velocity.x = direction * SPEED + platform_velocity.x

	# Apply gravity
	velocity.y += GRAVITY * delta

	# Cap the fall speed to prevent teleportation-like falling
	const MAX_FALL_SPEED = 9000.0
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	# Handle jumping
	if not is_game_win and Input.is_action_just_pressed("ui_up") and body.is_on_floor():
		velocity.y = JUMP_FORCE

	# Only freeze Chonki after win once on the floor
	if is_game_win and body.is_on_floor():
		body.velocity = Vector2(0, 0)
		return

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
	var current_time: float = Time.get_unix_time_from_system()
	return "ouch" if (hit_time != null and current_time - hit_time <= HIT_RECOVERY_TIME) else ""

func get_run_sprite():
	if velocity.x != 0:
		if not run_sound.playing && !is_game_win:
			run_sound.play()
		else:
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
	return "rest" if is_game_win else ""

func handle_sprite_flip():
	if is_game_win:
		sprite.flip_h = false
	elif Input.is_action_just_pressed("ui_left"):
		sprite.flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
		sprite.flip_h = false

func update_sprite() -> void:
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

	if velocity.x != 0 or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		last_action_time = Time.get_unix_time_from_system()

	for next_sprite in possible_next_sprites:
		if next_sprite != null and next_sprite != "":
			sprite.play(next_sprite)
			handle_sprite_flip()
			return

func _on_player_out_of_hearts():
	if not is_game_over:
		is_game_over = true
		player_die()

func player_die():
	# Play sleep animation
	sprite.play("sleep")
	# Prevent player movement and input
	set_process(false)
	set_physics_process(false)
	body.set_process(false)
	body.set_physics_process(false)
	await get_tree().create_timer(3.0, false).timeout
	FadeTransition.fade_out_and_change_scene(get_tree().current_scene.scene_file_path, 0.0, 1.0)

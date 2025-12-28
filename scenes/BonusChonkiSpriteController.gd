# BonusChonkiSpriteController.gd
extends AnimatedSprite2D

var velocity: Vector2 = Vector2.ZERO
var is_on_floor: bool = false
var is_chonki_sliding: bool = false
var can_slide_on_release: bool = false
var is_game_win: bool = false
var hit_time: float = 0.0
var last_action_time: float = 0.0
var time_held: float = 0.0
var chonki_state: int = 0

var is_sliding: bool = false
var has_jetpack: bool = false

var slide_tween: Tween

func _ready() -> void:
	GlobalSignals.connect("chonki_state_updated", _on_chonki_state_updated)
	GlobalSignals.connect("player_hit", _on_player_hit)
	GlobalSignals.connect("win_game", func(_zoom_intensity: float): is_game_win = true)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)
	GlobalSignals.connect("chonki_touched_kite", _on_chonki_touched_kite)
	GlobalSignals.connect("slide_start", _on_slide_start)
	GlobalSignals.connect("slide_end", _on_slide_end)

func _on_slide_start() -> void:
	is_sliding = true

func _on_slide_end() -> void:
	is_sliding = false

func _on_chonki_state_updated(new_velocity, on_floor, sliding, can_slide, last_action, time_held_input, state, jetpack = false) -> void:
	self.velocity = new_velocity
	self.is_on_floor = on_floor
	self.is_sliding = sliding
	self.can_slide_on_release = can_slide
	self.last_action_time = last_action
	self.time_held = time_held_input
	self.chonki_state = state
	self.has_jetpack = jetpack
	
	update_sprite()
	play_sound_effects()

func _on_player_hit(_damage_source: String) -> void:
	hit_time = Time.get_unix_time_from_system()
	GlobalSignals.play_sfx.emit("ouch")

func _on_player_out_of_hearts() -> void:
	pass

func _on_chonki_touched_kite() -> void:
	play("run")
	frame = 10

func play_sound_effects() -> void:
	match animation:
		"sleep":
			GlobalSignals.play_sfx.emit("rest")
		"jump":
			GlobalSignals.stop_sfx.emit("rest")
		"idle":
			GlobalSignals.stop_sfx.emit("rest")
		"run":
			GlobalSignals.stop_sfx.emit("rest")

func get_player_injured_sprite() -> String:
	var current_time: float = Time.get_unix_time_from_system()
	return "ouch" if (hit_time != 0.0 and current_time - hit_time <= PhysicsConstants.HIT_RECOVERY_TIME) else ""

func get_run_sprite() -> String:
	if velocity.x != 0:
		return "run"
	return ""

func get_jump_sprite() -> String:
	if not is_on_floor:
		GlobalSignals.stop_sfx.emit("run")
		return "jump"
	return ""

func get_sleep_sprite() -> String:
	var secs_since_action = Time.get_unix_time_from_system() - last_action_time
	if secs_since_action >= 15:
		return "sleep"
	return ""

func get_rest_sprite() -> String:
	var secs_since_action = Time.get_unix_time_from_system() - last_action_time
	if secs_since_action >= AnimationConstants.TIME_UNTIL_REST:
		return "rest"
	return ""

func get_win_sprite() -> String:
	if is_game_win:
		return "run"
	return ""

func get_attack_sprite() -> String:
	if chonki_state == 2:
		return "ram"
	return ""

func get_idle_sprite() -> String:
	return "idle"

func handle_sprite_flip() -> void:
	if is_game_win:
		flip_h = false
	elif Input.is_action_just_pressed("ui_left"):
		flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
		flip_h = false

func update_sprite() -> void:
	if chonki_state == 3:
		play("idle")
		frame = 0
		return

	var possible_next_sprites = [
		get_win_sprite(),
		get_player_injured_sprite(),
		get_jump_sprite(),
		get_run_sprite(),
		get_sleep_sprite(),
		get_rest_sprite(),
		get_attack_sprite(),
		get_idle_sprite()
	]

	for next_sprite in possible_next_sprites:
		if next_sprite != "":
			if animation != next_sprite:
				play(next_sprite)
			handle_sprite_flip()
			return

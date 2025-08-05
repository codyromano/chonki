# ChonkiSpriteController.gd
extends AnimatedSprite2D

# State variables
var velocity: Vector2 = Vector2.ZERO
var is_on_floor: bool = false
var is_chonki_sliding: bool = false
var can_slide_on_release: bool = false
var is_game_win: bool = false
var hit_time: float = 0.0
var last_action_time: float = 0.0
var time_held: float = 0.0
var chonki_state: int = 0 # Corresponds to ChonkiState enum

var slide_tween: Tween

func _ready() -> void:
	GlobalSignals.connect("chonki_state_updated", _on_chonki_state_updated)
	GlobalSignals.connect("player_hit", _on_player_hit)
	GlobalSignals.connect("win_game", func(): is_game_win = true)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)
	GlobalSignals.connect("chonki_touched_kite", _on_chonki_touched_kite)

func _on_chonki_state_updated(new_velocity, on_floor, sliding, can_slide, last_action, time_held_input, state) -> void:
	self.velocity = new_velocity
	self.is_on_floor = on_floor
	self.is_chonki_sliding = sliding
	self.can_slide_on_release = can_slide
	self.last_action_time = last_action
	self.time_held = time_held_input
	self.chonki_state = state
	
	update_sprite()
	play_sound_effects()

func _on_player_hit() -> void:
	hit_time = Time.get_unix_time_from_system()
	GlobalSignals.play_sfx.emit("ouch")

func _on_player_out_of_hearts() -> void:
	# Let Chonki fall first
	await get_tree().create_timer(0.5).timeout
	play("sleep")

func _on_chonki_touched_kite() -> void:
	play("run")
	frame = 10

# --- Sound Logic ---

func play_sound_effects() -> void:
	match animation:
		"sleep":
			GlobalSignals.play_sfx.emit("rest")
		"jump":
			GlobalSignals.stop_sfx.emit("rest")
		"idle":
			GlobalSignals.stop_sfx.emit("rest")

# --- Sprite Logic ---

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
	if secs_since_action >= 5:
		return "rest"
	return ""

func get_slide_sprite() -> String:
	if is_chonki_sliding and can_slide_on_release:
		frame = 0
		var target_rot = -5 if flip_h else 5
		if slide_tween == null or not slide_tween.is_running():
			slide_tween = create_tween()
			slide_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			slide_tween.tween_property(self, "rotation_degrees", target_rot, PhysicsConstants.DECEL_TIME * 0.5)
			slide_tween.tween_property(self, "rotation_degrees", 0, PhysicsConstants.DECEL_TIME * 0.5)
		return "run"
	return ""

func get_idle_sprite() -> String:
	return "idle"

func get_win_game_sprite() -> String:
	return "rest" if is_game_win else ""

func handle_sprite_flip() -> void:
	if is_game_win:
		flip_h = false
	elif Input.is_action_just_pressed("ui_left"):
		flip_h = true
	elif Input.is_action_just_pressed("ui_right"):
		flip_h = false

func update_sprite() -> void:
	if chonki_state == 3: # ChonkiState.HANG_ON
		play("idle")
		frame = 0
		return

	var possible_next_sprites = [
		get_win_game_sprite(),
		get_slide_sprite(),
		get_player_injured_sprite(),
		get_jump_sprite(),
		get_run_sprite(),
		get_sleep_sprite(),
		get_rest_sprite(),
		get_idle_sprite()
	]

	for next_sprite in possible_next_sprites:
		if next_sprite != "":
			if animation != next_sprite:
				play(next_sprite)
			handle_sprite_flip()
			return

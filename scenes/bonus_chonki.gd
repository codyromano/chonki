# Use centralized physics constants: PhysicsConstants.*
extends Node2D

# BONUS CHONKI

@export var debug_start_marker: Marker2D
@onready var body         : CharacterBody2D    = $ChonkiCharacter
@onready var sprite       : AnimatedSprite2D   = $ChonkiCharacter/AnimatedSprite2D

@export var heart_texture: Texture2D
@export var jump_multiplier: float = 1.0
@export var midair_jumps: int = 0
@export var speed_multiplier: float = 0.375
@export var jetpack_thrust_speed: float = -800.0

# An item or character carried on Gus's back
@export var carried_entity: Node2D
@onready var carried_entity_marker: Marker2D = find_child('CarriedEntityMarker')

@export var initial_camera_zoom: Vector2 = Vector2(0.2, 0.2)

enum ChonkiState { IDLE, RUN, ATTACK, HANG_ON }

var state : ChonkiState = ChonkiState.IDLE
var last_action_time : float = Time.get_unix_time_from_system() - 60.0
var velocity: Vector2 = Vector2.ZERO
var chonki_hit = false
var original_collision_mask: int
var hit_time: float
var is_game_win: bool = false
@export var win_zoom_intensity: float = 0.5

@onready var camera2d: Camera2D = $ChonkiCharacter/Camera2D
var fade_rect: ColorRect
@onready var hud = get_tree().get_first_node_in_group("HUDControl")
@onready var camera = find_child('Camera2D')

var is_chonki_sliding = false

var time_held: float = 0.0
var current_speed: float = PhysicsConstants.SPEED * speed_multiplier
var can_slide_on_release: bool = false

var is_running_sound_playing: bool = false
var is_backflipping: bool = false
var is_frozen: bool = false
var remaining_midair_jumps: int = 0
var is_midair_jumping: bool = false
var has_jetpack: bool = false

func _ready() -> void:
	GlobalSignals.player_registered.emit(self)
	GlobalSignals.set_chonki_frozen.connect(_on_chonki_frozen)
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	GlobalSignals.collected_jetpack.connect(_on_collected_jetpack)
	
	if debug_start_marker:
		global_position = debug_start_marker.global_position
		
	GlobalSignals.connect("player_hit", on_player_hit)
	GlobalSignals.connect("win_game", on_win_game)
	GlobalSignals.connect("player_jump", _on_player_jump)
	GlobalSignals.connect("backflip_triggered", _on_backflip_triggered)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)
	
	GameState.reset()
	PlayerInventory.reset_hearts()
	# Restore earned midair jumps from persistent inventory
	midair_jumps = PlayerInventory.get_earned_midair_jumps()
	# Cache and set total_stars for this level by scene path, using CollectibleStar group
	var level_path = get_tree().current_scene.scene_file_path
	var total_stars = GameState.get_total_stars_for_level(level_path)
	if total_stars == 0:
		total_stars = get_tree().get_nodes_in_group("CollectibleStar").size()
		GameState.set_total_stars_for_level(level_path, total_stars)
	else:
		GameState.total_stars = total_stars
	# Set initial camera zoom
	camera2d.zoom = initial_camera_zoom
	# Create a fullscreen ColorRect for fade effect in a CanvasLayer
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	add_child(canvas_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1000
	canvas_layer.add_child(fade_rect)
	fade_rect.visible = false
	
	position_carried_entity_on_back()
	
	var root = get_tree().current_scene
	var high_score_hud = root.get_node_or_null("HighScoreHUD")
	if high_score_hud:
		var control = high_score_hud.get_node_or_null("Control")
		if control:
			var tween = create_tween()
			tween.tween_property(control, "modulate:a", 1.0, 0.5)

func _on_chonki_frozen(frozen: bool) -> void:
	is_frozen = frozen

func format_number(num: int) -> String:
	var abbreviated_num = round(num / 10)
	var str_num = str(abbreviated_num)
	var formatted = ""
	var count = 0
	
	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_num[i] + formatted
		count += 1
	
	return formatted
	
func position_carried_entity_on_back() -> void:
	if carried_entity:
		carried_entity.global_position = carried_entity_marker.global_position

#func _on_chonki_slide_status(is_sliding: bool) -> void:
#	is_chonki_sliding = is_sliding	
	
func _on_chonki_touched_kite(kite_position: Vector2, kite_rotation_deg: int) -> void:
	# Calculate half the sprite height for foot alignment
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var half_h = frame_tex.get_size().y * sprite.scale.y * 0.5
	# Tween Chonki so his feet sit at the kite's collision shape center
	var target_pos = kite_position + Vector2(0, half_h)
	# Create a smoother attach animation over 0.3 seconds
	var tween = create_tween()
	tween.tween_property(body, "global_position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	# Enter hang-on state when touching kite
	state = ChonkiState.HANG_ON

	# Rotate Chonki to hang pose
	# Immediately align Chonki’s rotation to kite
	body.rotation_degrees = kite_rotation_deg - 90
	# Freeze on idle first frame
	sprite.play("run")
	sprite.frame = 10
	# Stop ongoing movement
	velocity = Vector2.ZERO
	# body.velocity = velocity

func on_win_game(zoom_intensity: float = 0.5) -> void:
	is_game_win = true
	win_zoom_intensity = zoom_intensity
	# Wait for Chonki to land on the floor before spawning hearts
	await wait_for_chonki_to_land()
	GlobalSignals.spawn_hearts_begin.emit()
	# Start fade out and scene transition after 5 seconds using the autoload
	FadeTransition.fade_out_and_change_scene("res://scenes/final_animation_sequence.tscn", 5.0, 3.0)

func wait_for_chonki_to_land() -> void:
	while not body.is_on_floor():
		await get_tree().process_frame

func show_high_score_notification(score: int) -> void:
	var sniglet_font: Font = preload("res://fonts/Sniglet-Regular.ttf")
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	
	var notification_control = Control.new()
	notification_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	notification_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notification_control.modulate.a = 0.0
	canvas_layer.add_child(notification_control)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notification_control.add_child(center_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_container.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = "New High Score!"
	title_label.add_theme_font_override("font", sniglet_font)
	title_label.add_theme_font_size_override("font_size", 125)
	title_label.add_theme_color_override("font_color", Color(1, 1, 0.529412, 1))
	title_label.add_theme_constant_override("outline_size", 20)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_label)
	
	var score_label = Label.new()
	score_label.text = format_number(score)
	score_label.add_theme_font_override("font", sniglet_font)
	score_label.add_theme_font_size_override("font_size", 150)
	score_label.add_theme_color_override("font_color", Color(1, 1, 0.529412, 1))
	score_label.add_theme_constant_override("outline_size", 20)
	score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(score_label)
	
	var tween = create_tween()
	tween.tween_property(notification_control, "modulate:a", 1.0, 0.5)
	tween.tween_interval(2.5)
	tween.tween_property(notification_control, "modulate:a", 0.0, 0.5)

func on_player_hit(_damage_source: String) -> void:
	$ChonkiCharacter/AudioOuch.play()
	hit_time = Time.get_unix_time_from_system()

func _on_player_out_of_hearts() -> void:
	sprite.play("ouch")
	set_physics_process(false)
	body.set_physics_process(false)
	
	var root = get_tree().current_scene
	var score_hud = root.get_node_or_null("ScoreHUD")
	var current_score = 0
	var is_new_high_score = false
	
	if score_hud:
		var score_value_label = score_hud.find_child("ScoreValue", true, false)
		if score_value_label:
			current_score = score_value_label.score
			if current_score > GameState.bonus_high_score:
				is_new_high_score = true
				GameState.update_bonus_high_score(current_score)
	
	if is_new_high_score:
		show_high_score_notification(current_score)
		await get_tree().create_timer(4.0).timeout
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 2.0)
	fade_rect.visible = true
	await tween.finished
	
	get_tree().reload_current_scene()
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	GlobalSignals.chonki_state_updated.emit(velocity, body.is_on_floor(), is_chonki_sliding, can_slide_on_release, last_action_time, time_held, state, has_jetpack)
	
	# Store original velocity before collision processing
	var pre_collision_velocity = body.velocity
	
	body.move_and_slide()
	
	# Handle BigFloor collision filtering - restore horizontal movement if blocked by BigFloor
	if body.get_slide_collision_count() > 0:
		var was_blocked_by_bigfloor = false
		for i in body.get_slide_collision_count():
			var collision = body.get_slide_collision(i)
			var collider = collision.get_collider()
			var normal = collision.get_normal()
			
			# Check if this is a BigFloor collision blocking horizontal movement
			if collider and collider.name == "BigFloor" and abs(normal.x) > 0.5:
				was_blocked_by_bigfloor = true
				break
		
		# If BigFloor blocked horizontal movement, restore it
		if was_blocked_by_bigfloor:
			body.velocity.x = pre_collision_velocity.x * speed_multiplier
	
func get_platform_velocity() -> Vector2:
	# Returns the velocity of the platform Chonki is standing on, or Vector2.ZERO if not on a moving platform
	if body.is_on_floor():
		var collision = body.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			
			if collider and collider.has_method("get_platform_velocity"):
				# Support any platform with get_platform_velocity method
				return collider.get_platform_velocity()
	return Vector2.ZERO

func handle_movement(delta: float) -> void:

	# Don't process movement if Chonki is frozen
	if is_frozen:
		velocity = Vector2.ZERO
		body.velocity = Vector2.ZERO
		return
		
	if state == ChonkiState.HANG_ON:
		# ... (hang on logic is correct)
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			# Base jump impulse
			velocity.x = PhysicsConstants.SPEED * speed_multiplier
			velocity.y = PhysicsConstants.JUMP_FORCE * jump_multiplier
			# Apply additional impulse proportional to swing factor (reduced max)
			var jump_mult = 1.0 * (4.0 / 3.0)
			velocity *= jump_mult
			# Reset rotation and resume normal state
			body.rotation_degrees = 0
			state = ChonkiState.IDLE
			# Reset hang offset
		# Apply velocity (or remain zero)
		body.velocity = velocity
		return
	
	var platform_velocity = get_platform_velocity()
	var direction: float = 0.0

	if not is_game_win and not is_chonki_sliding:
		direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	elif not is_game_win:
		# If sliding, check for direction input to abort the slide
		direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		if direction != 0:
			# Player pressed a direction key while sliding - abort the slide
			is_chonki_sliding = false

	if direction != 0 or Input.is_action_just_pressed("ui_up"):
		last_action_time = Time.get_unix_time_from_system()

	if is_chonki_sliding:
		velocity.x = move_toward(velocity.x, 0, PhysicsConstants.DECELERATION * speed_multiplier * delta)
		# Stop sliding if velocity reaches zero, not on floor, or hit a wall (but ignore BigFloor)
		var hit_wall = false
		if body.get_slide_collision_count() > 0:
			for i in body.get_slide_collision_count():
				var collision = body.get_slide_collision(i)
				# Check if collision normal is mostly horizontal (wall collision)
				if abs(collision.get_normal().x) > 0.5:
					var collider = collision.get_collider()
					# Ignore BigFloor collisions for sliding
					if collider and collider.name == "BigFloor":
						continue
					hit_wall = true
					break
		
		if velocity.x == 0 or not body.is_on_floor() or hit_wall:
			is_chonki_sliding = false
	elif direction != 0:
		time_held += delta
		var speed_fraction = min(time_held / PhysicsConstants.TIME_UNTIL_MAX_SPEED, 1.0)
		current_speed = lerp(PhysicsConstants.SPEED, PhysicsConstants.MAX_SPEED, speed_fraction)
		velocity.x = direction * current_speed * speed_multiplier + platform_velocity.x
		
		if current_speed >= PhysicsConstants.MAX_SPEED * speed_multiplier:
			can_slide_on_release = true

		if not is_running_sound_playing:
			GlobalSignals.play_sfx.emit("run")
			is_running_sound_playing = true
	else: # Not sliding and no direction input
		time_held = 0
		current_speed = PhysicsConstants.SPEED * speed_multiplier
		
		if can_slide_on_release:
			is_chonki_sliding = true
		
		can_slide_on_release = false
		
		if is_running_sound_playing:
			GlobalSignals.stop_sfx.emit("run")
			is_running_sound_playing = false
		
		# Only apply regular deceleration if NOT sliding
		if not is_chonki_sliding:
			velocity.x = move_toward(velocity.x, 0, PhysicsConstants.DECELERATION_NON_SLIDING * speed_multiplier * delta)

	# Apply jetpack thrust if collected, otherwise apply gravity
	if has_jetpack:
		velocity.y = jetpack_thrust_speed
	else:
		velocity.y += PhysicsConstants.GRAVITY * delta
		# Cap the fall speed to prevent teleportation-like falling
		if velocity.y > PhysicsConstants.MAX_FALL_SPEED:
			velocity.y = PhysicsConstants.MAX_FALL_SPEED

	# Only freeze Chonki after win once on the floor
	if is_game_win and body.is_on_floor():
		body.velocity = Vector2(0, 0)
		return

	body.velocity = velocity

func player_die():
	# Play sleep animation
	# sprite.play("sleep")
	# Prevent player movement and input
	set_process(false)
	set_physics_process(false)
	body.set_process(false)
	body.set_physics_process(false)
	await get_tree().create_timer(3.0, false).timeout
	
	if PlayerInventory.last_damage_source == "ocean":
		FadeTransition.show_message_and_reload("Gus went home to take a bath", 0.25, 3.0)
	elif PlayerInventory.last_damage_source == "goose_boss":
		FadeTransition.show_message_and_reload("Don't mess with mama goose", 0.25, 3.0)
	else:
		FadeTransition.fade_out_and_change_scene(get_tree().current_scene.scene_file_path, 0.0, 1.0)

# TODO: String param should be an enum here
func _on_player_jump(intensity: float, entity_applying_force: String):
	# Allow objects such as trampolines to apply jump force to the player even
	# when the player is not on the ground.
	var can_jump = false
	var is_midair_jump = false
	
	if body.is_on_floor():
		# Always allow jumping when on floor
		can_jump = true
		# Reset midair jump counter when landing
		remaining_midair_jumps = midair_jumps
		# Reset midair jumping flag when landing
		is_midair_jumping = false
	elif entity_applying_force != "player":
		# External forces (trampolines, etc.) always work
		can_jump = true
	elif remaining_midair_jumps > 0 and not is_midair_jumping:
		# Allow midair jump if we have jumps remaining and not currently performing one
		can_jump = true
		is_midair_jump = true
		remaining_midair_jumps -= 1
	
	if not is_game_win and can_jump:
		velocity.y = PhysicsConstants.JUMP_FORCE * jump_multiplier * intensity
		# Play different sound for midair jumps
		if is_midair_jump:
			GlobalSignals.play_sfx.emit("midair_jump")
			# Trigger backflip animation for midair jumps
			_perform_midair_backflip()
		else:
			GlobalSignals.play_sfx.emit("jump")

func _on_backflip_triggered():
	# Prevent multiple simultaneous backflips
	if is_backflipping:
		return
		
	is_backflipping = true
	
	# Play bark sound at the start of rotation
	GlobalSignals.play_sfx.emit("bark")
	
	# Perform 360 degree rotation on sprite only (not the body/camera) over 0.5 seconds
	var start_rotation = sprite.rotation_degrees
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", start_rotation + 360, 0.5)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Reset the backflip flag when animation completes
	await tween.finished
	
	# Ensure sprite rotation is exactly reset to 0 to prevent interference with sprite flipping
	sprite.rotation_degrees = 0
	
	is_backflipping = false

func _process(_delta) -> void:
	position_carried_entity_on_back() 
	
func _perform_midair_backflip():
	# Perform a quick backflip during midair jump
	# Prevent other midair jumps while this animation is in progress
	is_midair_jumping = true
	
	# Perform 360 degree rotation on sprite only over 0.5 seconds
	var start_rotation = sprite.rotation_degrees
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", start_rotation + 360, 0.5)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Reset sprite rotation when animation completes
	await tween.finished
	
	# Always reset to 0 to ensure Gus lands on his feet
	sprite.rotation_degrees = 0
	
	# Allow next midair jump
	is_midair_jumping = false

func _on_secret_letter_collected(_letter_item: PlayerInventory.Item):
	PlayerInventory.increment_midair_jumps()
	midair_jumps += 1

func _exit_tree() -> void:
	GlobalSignals.player_unregistered.emit()


func _on_jetpack_body_entered(_jetpack_body: Node2D) -> void:
	pass

func _on_collected_jetpack() -> void:
	has_jetpack = true
	var huds = get_tree().get_nodes_in_group("HUDControl")
	for hud in huds:
		var control = hud.get_node_or_null("Control")
		if control:
			var tween = create_tween()
			tween.tween_property(control, "modulate:a", 1.0, 0.5)

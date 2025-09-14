# Use centralized physics constants: PhysicsConstants.*
extends Node2D

@export var debug_start_marker: Marker2D
@onready var body         : CharacterBody2D    = $ChonkiCharacter
@onready var sprite       : AnimatedSprite2D   = $ChonkiCharacter/AnimatedSprite2D

@export var heart_texture: Texture2D
@export var jump_multiplier: float = 1.0

enum ChonkiState { IDLE, RUN, ATTACK, HANG_ON }

var state : ChonkiState = ChonkiState.IDLE
var last_action_time : float = Time.get_unix_time_from_system() - 60.0
var velocity: Vector2 = Vector2.ZERO
var chonki_hit = false
var original_collision_mask: int
var hit_time: float
var is_game_win: bool = false
@export var win_zoom_intensity: float = 0.5  # Default zoom intensity - made export for camera access

# TODO: Add a signal for kite rotated and update chonki's
# rotation accordingly 


@onready var camera2d: Camera2D = $ChonkiCharacter/Camera2D
var fade_rect: ColorRect
@onready var hud = get_tree().get_first_node_in_group("HUDControl")
var is_game_over = false
var is_chonki_sliding = false

var hang_direction: int = 0  # Direction of kite (+1 right, -1 left)

var target_rotation_degrees: int
var hang_offset: Vector2 = Vector2.ZERO
var swing_factor: float = 1.0  # Current swing speed factor from kite

var time_held: float = 0.0
var current_speed: float = PhysicsConstants.SPEED
var can_slide_on_release: bool = false

var is_running_sound_playing: bool = false
var is_backflipping: bool = false

# Signal to indicate Chonki has landed and hearts have spawned
signal chonki_landed_and_hearts_spawned(zoom_intensity: float)

func _ready() -> void:
	GlobalSignals.player_registered.emit(self)
	
	if debug_start_marker:
		global_position = debug_start_marker.global_position
		
	#sprite.play("sleep")
	GlobalSignals.connect("player_hit", on_player_hit)
	GlobalSignals.connect("win_game", on_win_game)
	GlobalSignals.connect("player_out_of_hearts", _on_player_out_of_hearts)
	GlobalSignals.connect("chonki_touched_kite", _on_chonki_touched_kite)
	GlobalSignals.connect("kite_rotated", _on_kite_rotated)
	GlobalSignals.connect("game_zoom_level", _on_game_zoom_level)
	GlobalSignals.connect("player_jump", _on_player_jump)
	GlobalSignals.connect("backflip_triggered", _on_backflip_triggered)
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
	# Set initial zoom level from signal or default
	var initial_zoom = 0.25
	camera2d.zoom = Vector2(initial_zoom, initial_zoom)
	# Create a fullscreen ColorRect for fade effect
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1000
	add_child(fade_rect)
	fade_rect.visible = false

func _on_game_zoom_level(zoom_level: float, zoom_duration: float = 2.0) -> void:
	if camera2d.has_method("_on_animate_camera_zoom_level"):
		camera2d._on_animate_camera_zoom_level(zoom_level, zoom_duration)
	else:
		camera2d.zoom = Vector2(zoom_level, zoom_level)
	
var kite_rotate_tween

#func _on_chonki_slide_status(is_sliding: bool) -> void:
#	is_chonki_sliding = is_sliding
	
func _rotate_on_kite(initial_degrees: int) -> void:
	if kite_rotate_tween == null:
		kite_rotate_tween = create_tween()
		kite_rotate_tween.set_loops()
		rotation_degrees = initial_degrees
		kite_rotate_tween.tween_property(self, "rotation_degrees", initial_degrees - 20, 4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		kite_rotate_tween.tween_property(self, "rotation_degrees", initial_degrees + 20, 4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	
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
	# Determine hang direction based on kite rotation (>=0 => right)
	hang_direction = 1 if kite_rotation_deg >= 0 else -1
	# Rotate Chonki to hang pose
	# Immediately align Chonki’s rotation to kite
	body.rotation_degrees = kite_rotation_deg - 90
	# Freeze on idle first frame
	sprite.play("run")
	sprite.frame = 10
	# Stop ongoing movement
	velocity = Vector2.ZERO
	# body.velocity = velocity
	# Store foot offset for rotation alignment (feet remain against kite)
	hang_offset = Vector2(0, half_h)

func on_win_game(zoom_intensity: float = 0.5) -> void:
	print("Chonki on_win_game called with zoom_intensity: ", zoom_intensity)
	is_game_win = true
	win_zoom_intensity = zoom_intensity
	print("Chonki win_zoom_intensity set to: ", win_zoom_intensity)
	# Wait for Chonki to land on the floor before spawning hearts
	await wait_for_chonki_to_land()
	GlobalSignals.spawn_hearts_begin.emit()
	# spawn_floating_hearts()
	emit_signal("chonki_landed_and_hearts_spawned", zoom_intensity)
	# Start fade out and scene transition after 5 seconds using the autoload
	FadeTransition.fade_out_and_change_scene("res://scenes/level_result.tscn", 5.0, 3.0)

func wait_for_chonki_to_land() -> void:
	while not body.is_on_floor():
		await get_tree().process_frame

func on_player_hit() -> void:
	GlobalSignals.heart_lost.emit()
	$ChonkiCharacter/AudioOuch.play()
	hit_time = Time.get_unix_time_from_system()
	
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	GlobalSignals.chonki_state_updated.emit(velocity, body.is_on_floor(), is_chonki_sliding, can_slide_on_release, last_action_time, time_held, state)
	
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
			body.velocity.x = pre_collision_velocity.x
	
func get_platform_velocity() -> Vector2:
	# Returns the velocity of the platform Chonki is standing on, or Vector2.ZERO if not on a moving platform
	if body.is_on_floor():
		var collision = body.get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			
			if collider and collider.name == "CherryTreeBody":
				# Zoom out when the game starts
				GlobalSignals.animate_camera_zoom_level.emit(0.17)
			
			if collider and collider.has_method("get_platform_velocity"):
				# Support any platform with get_platform_velocity method
				return collider.get_platform_velocity()
	return Vector2.ZERO

func handle_movement(delta: float) -> void:
	if state == ChonkiState.HANG_ON:
		# ... (hang on logic is correct)
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			# Base jump impulse
			velocity.x = hang_direction * PhysicsConstants.SPEED
			velocity.y = PhysicsConstants.JUMP_FORCE * jump_multiplier
			# Apply additional impulse proportional to swing factor (reduced max)
			var jump_mult = 1.0 + (swing_factor - 1.0) * (4.0 / 3.0)
			velocity *= jump_mult
			# Reset rotation and resume normal state
			body.rotation_degrees = 0
			state = ChonkiState.IDLE
			# Reset hang offset
			hang_offset = Vector2.ZERO
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
		velocity.x = move_toward(velocity.x, 0, PhysicsConstants.DECELERATION * delta)
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
		velocity.x = direction * current_speed + platform_velocity.x
		
		if current_speed >= PhysicsConstants.MAX_SPEED:
			can_slide_on_release = true
		
		if not is_running_sound_playing:
			GlobalSignals.play_sfx.emit("run")
			is_running_sound_playing = true
	else: # Not sliding and no direction input
		time_held = 0
		current_speed = PhysicsConstants.SPEED
		
		if can_slide_on_release:
			is_chonki_sliding = true
		
		can_slide_on_release = false
		
		if is_running_sound_playing:
			GlobalSignals.stop_sfx.emit("run")
			is_running_sound_playing = false
		
		# Only apply regular deceleration if NOT sliding
		if not is_chonki_sliding:
			velocity.x = move_toward(velocity.x, 0, PhysicsConstants.DECELERATION_NON_SLIDING * delta)

	var current_time = Time.get_unix_time_from_system()

	if hit_time != null && current_time - hit_time <= PhysicsConstants.HIT_RECOVERY_TIME:
		velocity.x = 2000 if sprite.flip_h else -2000
		velocity.y = 1000
		body.velocity = velocity
		return
	elif hit_time != null && current_time - hit_time >= PhysicsConstants.HIT_RECOVERY_TIME && original_collision_mask > 0:
		pass

	# Apply gravity
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
	sprite.play("sleep")
	# Prevent player movement and input
	set_process(false)
	set_physics_process(false)
	body.set_process(false)
	body.set_physics_process(false)
	await get_tree().create_timer(3.0, false).timeout
	FadeTransition.fade_out_and_change_scene(get_tree().current_scene.scene_file_path, 0.0, 1.0)

# Handler to update Chonki position as the kite rotates while hanging
func _on_kite_rotated(kite_position: Vector2, kite_rotation_deg: int, factor: float) -> void:
	if state == ChonkiState.HANG_ON:
		# Update swing factor
		swing_factor = factor
		# Compute desired offset and rotation
		var rotated_offset = hang_offset.rotated(deg_to_rad(kite_rotation_deg))
		var target_pos = kite_position + rotated_offset
		var target_rot = kite_rotation_deg - 90
		# Smoothly interpolate position
		body.global_position = body.global_position.lerp(target_pos, 0.2)
		# Directly match kite orientation
		body.rotation_degrees = target_rot


# When Chonki loses all health, make him fall to the ground before dying
func _on_player_out_of_hearts():
	if not is_game_over:
		is_game_over = true
		# Disable player input and let gravity act
		set_process(false)
		set_physics_process(true)
		body.set_process(false)
		body.set_physics_process(true)
		# Optionally play a hit/fall animation here
		# Wait until Chonki is on the floor
		await wait_for_chonki_to_land()
		player_die()

# TODO: String param should be an enum here
func _on_player_jump(intensity: float, entity_applying_force: String):
	# Allow objects such as trampolines to apply jump force to the player even
	# when the player is not on the ground.
	if not is_game_win and (body.is_on_floor() || entity_applying_force != "player"):
		velocity.y = PhysicsConstants.JUMP_FORCE * jump_multiplier * intensity
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

func _exit_tree() -> void:
	GlobalSignals.player_unregistered.emit()

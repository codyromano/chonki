extends HBoxContainer

@onready var jump_icons: Array[TextureRect] = []
var first_icon_animated: bool = false
var active_blink_task: bool = false
var icons_revealed: int = 0
var icons_currently_visible: int = 0

func _ready() -> void:
	_initialize_jump_icons()
	_setup_visibility.call_deferred()

func _setup_visibility() -> void:
	if GameState.current_level == 2:
		visible = true
		_setup_signals()
		_restore_earned_icons()
	else:
		visible = false

func _initialize_jump_icons() -> void:
	for i in range(1, 6):
		var icon = find_child("Jump" + str(i)) as TextureRect
		if icon:
			jump_icons.append(icon)
			icon.modulate.a = 0.0
			icon.custom_minimum_size = Vector2(60, 60)
			icon.visible = true
		else:
			push_error("Jump icon not found: Jump" + str(i))

func _setup_signals() -> void:
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	GlobalSignals.midair_jump_consumed.connect(_on_midair_jump_consumed)
	GlobalSignals.midair_jumps_restored.connect(_on_midair_jumps_restored)

func _restore_earned_icons() -> void:
	var earned_jumps = PlayerInventory.get_earned_midair_jumps()
	for i in range(jump_icons.size()):
		if i < earned_jumps:
			jump_icons[i].modulate.a = 1.0
			jump_icons[i].scale = Vector2(1.0, 1.0)
		else:
			jump_icons[i].modulate.a = 0.0
	icons_revealed = earned_jumps
	icons_currently_visible = earned_jumps
	if earned_jumps > 0:
		first_icon_animated = true

func _on_secret_letter_collected(_letter_item: PlayerInventory.Item) -> void:
	if icons_revealed >= jump_icons.size():
		return
	
	if not is_visible_in_tree():
		return
	
	var icon = jump_icons[icons_revealed]
	icon.modulate.a = 0.0
	
	await get_tree().create_timer(6.0).timeout
	
	await _animate_icon_entrance(icon)
	_play_blink_animation(icon)
	
	icons_revealed += 1
	icons_currently_visible += 1

func _animate_icon_entrance(icon: TextureRect) -> void:
	await get_tree().process_frame
	
	var texture_size = Vector2.ZERO
	if icon.texture:
		texture_size = icon.texture.get_size()
	else:
		return
	
	var original_size_flags = icon.size_flags_horizontal
	var original_anchor_left = icon.anchor_left
	var original_anchor_top = icon.anchor_top
	var original_anchor_right = icon.anchor_right
	var original_anchor_bottom = icon.anchor_bottom
	var original_position = icon.position
	
	var final_global_position = icon.global_position
	
	icon.visible = true
	icon.modulate.a = 1.0
	icon.top_level = true
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.set_anchors_preset(Control.PRESET_CENTER)
	
	var viewport_size = get_viewport_rect().size
	
	var scaled_texture_size = texture_size * 4.0
	var center_position = (viewport_size / 2.0) - (scaled_texture_size / 2.0)
	
	icon.global_position = center_position
	icon.scale = Vector2(4.0, 4.0)
	icon.z_index = 101
	
	await get_tree().create_timer(1.5).timeout
	
	var move_tween = create_tween()
	move_tween.set_parallel(true)
	move_tween.tween_property(icon, "global_position", final_global_position, 2.5)
	move_tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 2.5)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.set_trans(Tween.TRANS_SINE)
	await move_tween.finished
	
	icon.top_level = false
	icon.size_flags_horizontal = original_size_flags
	icon.anchor_left = original_anchor_left
	icon.anchor_top = original_anchor_top
	icon.anchor_right = original_anchor_right
	icon.anchor_bottom = original_anchor_bottom
	icon.position = original_position
	icon.z_index = 0

func _play_blink_animation(icon: TextureRect) -> void:
	active_blink_task = true
	var blink_duration = 2.5
	var blink_interval = 0.15
	var elapsed_time = 0.0
	
	while elapsed_time < blink_duration:
		if not is_inside_tree() or icon == null or not active_blink_task:
			active_blink_task = false
			return
		icon.modulate.a = 0.0
		await get_tree().create_timer(blink_interval).timeout
		if not is_inside_tree() or icon == null or not active_blink_task:
			active_blink_task = false
			return
		icon.modulate.a = 1.0
		await get_tree().create_timer(blink_interval).timeout
		elapsed_time += blink_interval * 2
	
	icon.modulate.a = 1.0
	active_blink_task = false

func _on_midair_jump_consumed(_remaining: int) -> void:
	if active_blink_task:
		active_blink_task = false
		await get_tree().process_frame
	
	if icons_currently_visible > 0:
		icons_currently_visible -= 1
		var icon = jump_icons[icons_currently_visible]
		if icon.get_tree():
			var fade_tween = create_tween()
			fade_tween.tween_property(icon, "modulate:a", 0.0, 0.5)

func _on_midair_jumps_restored() -> void:
	if active_blink_task:
		active_blink_task = false
		await get_tree().process_frame
	
	icons_currently_visible = icons_revealed
	for i in range(icons_currently_visible):
		if i < jump_icons.size():
			var icon = jump_icons[i]
			if icon.get_tree() and icon.modulate.a < 1.0:
				var fade_tween = create_tween()
				fade_tween.tween_property(icon, "modulate:a", 1.0, 0.3)

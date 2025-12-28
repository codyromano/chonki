extends Camera2D

@export var target: Node2D
@export var duration: float = 5.0
@export var initial_zoom_setting: Vector2

var initial_zoom: Vector2

var tween: Tween
var initial_position: Vector2

func _ready():
	# Store initial camera state
	initial_zoom = zoom
	initial_position = global_position

	# Listen for camera zoom animation signal
	if GlobalSignals.has_signal("animate_camera_zoom_level"):
		GlobalSignals.animate_camera_zoom_level.connect(_on_animate_camera_zoom_level)

	# Listen for game_zoom_level signal directly
	if GlobalSignals.has_signal("game_zoom_level"):
		GlobalSignals.game_zoom_level.connect(_on_game_zoom_level)

func _process(_delta) -> void:
	initial_zoom = initial_zoom_setting
	GlobalSignals.camera_position_changed.emit(global_position)
	
func _on_game_zoom_level(zoom_level: float, zoom_duration: float = 2.0):
	make_current()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), zoom_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# Animate camera zoom to a given level over 4 seconds

func _on_animate_camera_zoom_level(zoom_level: float, zoom_duration: float = 2.0):
	# Ensure this camera is current before animating zoom
	make_current()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), zoom_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Only connect to chonki_landed_and_hearts_spawned if not already connected
	var node = get_parent()
	var _already_connected := false
	while node:
		if node.has_signal("chonki_landed_and_hearts_spawned"):
			var signal_list = node.get_signal_connection_list("chonki_landed_and_hearts_spawned")
			for conn in signal_list:
				# Defensive: Godot 4.x returns a dictionary with keys 'callable', 'flags', etc. Use if-else for compatibility.
				var callable = null
				if conn.has("callable"):
					callable = conn["callable"]
				if callable and callable.get_object() == self and callable.get_method() == "_on_chonki_landed_and_hearts_spawned":
					_already_connected = true
					break
			if not _already_connected:
				node.connect("chonki_landed_and_hearts_spawned", Callable(self, "_on_chonki_landed_and_hearts_spawned"))
			break
		node = node.get_parent()


# Called when Chonki has landed and hearts have spawned
func _on_chonki_landed_and_hearts_spawned(zoom_intensity: float = 0.5):
	if not target:
		return

	make_current()

	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)

	var target_position = target.global_position

	var target_zoom = Vector2(zoom_intensity, zoom_intensity)

	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_property(self, "global_position", target_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(self, "zoom", target_zoom, duration)
	tween.tween_property(self, "zoom", target_zoom, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func wait_for_target_to_land() -> void:
	while true:
		if "body" in target and target.body and target.body.is_on_floor():
			break
		await get_tree().process_frame

# Optional: Function to reset camera to initial state
func reset_camera():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "global_position", initial_position, duration)
	tween.tween_property(self, "global_position", initial_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "zoom", initial_zoom, duration)
	tween.tween_property(self, "zoom", initial_zoom, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

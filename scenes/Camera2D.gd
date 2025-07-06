extends Camera2D

@export var target: Node2D
@export var duration: float = 5.0

var tween: Tween
var initial_zoom: Vector2
var initial_position: Vector2


func _ready():
	# Store initial camera state
	initial_zoom = zoom
	initial_position = global_position
	print("[Camera2D] Ready. Initial zoom:", initial_zoom)

	# Listen for camera zoom animation signal
	if GlobalSignals.has_signal("animate_camera_zoom_level"):
		print("[Camera2D] Connecting to animate_camera_zoom_level signal.")
		GlobalSignals.animate_camera_zoom_level.connect(_on_animate_camera_zoom_level)
	else:
		print("[Camera2D] animate_camera_zoom_level signal not found on GlobalSignals!")

# Animate camera zoom to a given level over 4 seconds

func _on_animate_camera_zoom_level(zoom_level: float):
	print("[Camera2D] Received animate_camera_zoom_level signal with value:", zoom_level)
	# Ensure this camera is current before animating zoom
	make_current()
	if tween:
		print("[Camera2D] Killing existing tween.")
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	print("[Camera2D] Animating zoom to:", Vector2(zoom_level, zoom_level), "over 4 seconds.")
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), 4.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# TODO: This is a hack! Camera2D is a child of ChonkiCharacter, but the signal we need is on the Chonki node (the grandparent).
	# So we walk up the parent chain to find a node with the chonki_landed_and_hearts_spawned signal and connect to it.
	# If you refactor the scene tree, update this logic accordingly.
	var node = get_parent()
	var found = false
	while node:
		if node.has_signal("chonki_landed_and_hearts_spawned"):
			node.connect("chonki_landed_and_hearts_spawned", Callable(self, "_on_chonki_landed_and_hearts_spawned"))
			found = true
			break
		node = node.get_parent()
	# If not found, this camera will not zoom on win.


# Called when Chonki has landed and hearts have spawned
func _on_chonki_landed_and_hearts_spawned():
	if not target:
		return

	# Ensure this camera is current
	make_current()

	# Create a new tween
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate simultaneously

	# Calculate target position (center on the target)
	var target_position = target.global_position

	# Define zoom level (you can adjust this value as needed)
	var target_zoom = Vector2(0.5, 0.5)  # Zoom in 3x

	# Animate position to target
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_property(self, "global_position", target_position, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# Animate zoom
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

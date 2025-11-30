extends Area2D

@export var camera_zoom: Vector2

var zoom_timer: Timer = null
var is_player_inside: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		is_player_inside = true
		
		if zoom_timer:
			zoom_timer.queue_free()
		
		zoom_timer = Timer.new()
		zoom_timer.wait_time = 0.5
		zoom_timer.one_shot = true
		zoom_timer.timeout.connect(_on_zoom_timer_timeout)
		add_child(zoom_timer)
		zoom_timer.start()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		is_player_inside = false
		
		if zoom_timer:
			zoom_timer.queue_free()
			zoom_timer = null

func _on_zoom_timer_timeout() -> void:
	if is_player_inside:
		GlobalSignals.game_zoom_level.emit(camera_zoom.x, 2.0)
	
	if zoom_timer:
		zoom_timer.queue_free()
		zoom_timer = null

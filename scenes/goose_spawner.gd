extends Node2D

@export var chonki: CharacterBody2D
@export var spawn_interval: float = 5.0
@export var goose_speed: float = 300.0

var goose_scene: PackedScene = preload("res://scenes/composable/bonus_goose.tscn")

var spawn_timer: float = 0.0
var camera: Camera2D

func _ready() -> void:
	if chonki:
		camera = chonki.find_child("Camera2D", true, false)

func _process(delta: float) -> void:
	if not chonki or not camera:
		return
		
	if chonki.is_on_floor():
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_goose()

func _spawn_goose() -> void:
	if not camera:
		return
		
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.get_screen_center_position()
	var zoom = camera.zoom.x
	
	var screen_width = viewport_size.x / zoom
	var screen_height = viewport_size.y / zoom
	
	var spawn_x = camera_pos.x + randf_range(-screen_width * 0.5, screen_width * 0.5)
	var spawn_y = camera_pos.y - (screen_height * 0.6)
	
	var goose = goose_scene.instantiate()
	goose.global_position = Vector2(spawn_x, spawn_y)
	goose.z_index = 10
	
	get_tree().current_scene.add_child(goose)
	
	var travel_distance = screen_width * 1.5
	var duration = travel_distance / goose_speed
	
	var tween = create_tween()
	tween.tween_property(goose, "global_position:x", spawn_x - travel_distance, duration)
	tween.tween_callback(goose.queue_free)

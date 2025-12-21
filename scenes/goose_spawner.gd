extends Node2D

@export var chonki: CharacterBody2D
@export var spawn_interval: float = 5.0
@export var goose_speed: float = 300.0
@export var interval_decrease_rate: float = 0.25
@export var interval_decrease_every: float = 5.0
@export var min_spawn_interval: float = 0.5

var goose_scene: PackedScene = preload("res://scenes/composable/bonus_goose.tscn")

var spawn_timer: float = 0.0
var camera: Camera2D
var current_spawn_interval: float
var difficulty_timer: float = 0.0

func _ready() -> void:
	if chonki:
		camera = chonki.find_child("Camera2D", true, false)
	current_spawn_interval = spawn_interval

func _process(delta: float) -> void:
	if not chonki or not camera:
		return
		
	if chonki.is_on_floor():
		return
	
	difficulty_timer += delta
	
	if difficulty_timer >= interval_decrease_every:
		difficulty_timer = 0.0
		current_spawn_interval = max(current_spawn_interval - interval_decrease_rate, min_spawn_interval)
	
	spawn_timer += delta
	
	if spawn_timer >= current_spawn_interval:
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

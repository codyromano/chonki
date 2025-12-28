extends Node2D

@export var chonki: CharacterBody2D
@export var spawn_interval: float = 0.85
@export var goose_speed: float = 460.0
@export var initial_geese_per_spawn: int = 2
@export var geese_increase_amount: int = 1
@export var geese_increase_every: float = 10.0
@export var left_boundary: float = 6851.0
@export var right_boundary: float = 22525.0

var goose_scene: PackedScene = preload("res://scenes/composable/bonus_goose.tscn")

var spawn_timer: float = 0.0
var camera: Camera2D
var current_geese_per_spawn: int
var difficulty_timer: float = 0.0

func _ready() -> void:
	if chonki:
		camera = chonki.find_child("Camera2D", true, false)
	current_geese_per_spawn = initial_geese_per_spawn

func _process(delta: float) -> void:
	if not chonki or not camera:
		return
		
	if chonki.is_on_floor():
		return
	
	difficulty_timer += delta
	
	if difficulty_timer >= geese_increase_every:
		difficulty_timer = 0.0
		current_geese_per_spawn += geese_increase_amount
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_geese()

func _spawn_geese() -> void:
	if not camera:
		return
		
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.get_screen_center_position()
	var zoom = camera.zoom.x
	
	var screen_width = viewport_size.x / zoom
	var screen_height = viewport_size.y / zoom
	
	var goose_half_width = 465.0
	
	var viewport_left = camera_pos.x - (screen_width * 0.5)
	var viewport_right = camera_pos.x + (screen_width * 0.5)
	
	var spawn_left = max(viewport_left, left_boundary + goose_half_width)
	var spawn_right = min(viewport_right, right_boundary - goose_half_width)
	
	if spawn_right <= spawn_left:
		return
	
	for i in range(current_geese_per_spawn):
		var spawn_x = randf_range(spawn_left, spawn_right)
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

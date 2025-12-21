extends Node2D

@export var chonki: CharacterBody2D
@export var spawn_interval: float = 0.3
@export var cloud_speed_min: float = 200.0
@export var cloud_speed_max: float = 500.0

var cloud_scene: PackedScene = preload("res://scenes/composable/cloud.tscn")
var cloud_textures: Array[Texture2D] = [
	preload("res://assets/environment/cloud_spawn_01.png"),
	preload("res://assets/environment/cloud_spawn_02.png"),
	preload("res://assets/environment/cloud_spawn_03.png")
]

var spawn_timer: float = 0.0
var last_spawn_y: float = 0.0
var camera: Camera2D

func _ready() -> void:
	if chonki:
		camera = chonki.find_child("Camera2D", true, false)
	print("[CloudSpawner] Ready - chonki: ", chonki, " camera: ", camera)

func _process(delta: float) -> void:
	if not chonki or not camera:
		return
		
	if chonki.is_on_floor():
		return
	
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_cloud()

func _spawn_cloud() -> void:
	if not camera:
		print("[CloudSpawner] No camera found")
		return
		
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.get_screen_center_position()
	var zoom = camera.zoom.x
	
	var screen_width = viewport_size.x / zoom
	var screen_height = viewport_size.y / zoom
	
	var spawn_x = camera_pos.x + randf_range(-screen_width * 0.5, screen_width * 0.5)
	var spawn_y = camera_pos.y - (screen_height * 0.6)
	
	var cloud = cloud_scene.instantiate()
	cloud.global_position = Vector2(spawn_x, spawn_y)
	cloud.z_index = 10
	cloud.modulate = Color(1, 1, 1, 1)
	
	var texture_index = randi() % cloud_textures.size()
	cloud.texture = cloud_textures[texture_index]
	
	var parallax_factor = randf_range(0.3, 1.0)
	cloud.modulate.a = parallax_factor * 0.7
	
	var speed = lerp(cloud_speed_min, cloud_speed_max, 1.0 - parallax_factor)
	var travel_distance = screen_width * 1.5
	var duration = travel_distance / speed
	
	get_tree().current_scene.add_child(cloud)
	
	var tween = create_tween()
	tween.tween_property(cloud, "global_position:x", spawn_x - travel_distance, duration)
	tween.tween_callback(cloud.queue_free)

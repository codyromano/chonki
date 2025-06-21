extends Node2D

# Node from which the "item" spawns
@export var origin: Node2D
# Anything...a collectible, enemy, etc.
@export var item_scene: PackedScene

@export var duration: float = 2

@export var should_spawn: bool = false 

@export var wtf_hack: int = 7000

var item: Node2D
var did_spawn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !origin || !item_scene:
		push_error('Remember to set origin and item')
	
	item = item_scene.instantiate()
	add_child(item)
	
	# Spawned item is hidden at first
	item.visible = false
	item.modulate.a = 0

func _process(_delta):
	if !should_spawn:
		return
	
	# Item is previously freed
	if item == null:
		print("item previously freed")
		return
	
	if !item.visible:
		item.visible = true
		
		var tween = create_tween()
		tween.tween_property(item, "modulate:a", 1, duration)
		await tween.finished
	
	# print('pos.item: ', item.global_position)
	# print('pos.origin: ', origin.global_position)
	if item && origin:
		var pos = origin.global_position
		item.global_position = pos - Vector2(wtf_hack, -300)

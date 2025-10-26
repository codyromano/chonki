extends CanvasLayer

# Hide/show menu functionality
@export var is_health_visible: bool = false
@export var is_timer_visible: bool = false

# Configure available resources in level
@export var hearts_available: int = 3
@export var total_books_in_level: int = 5

# Preload UI resources
@onready var timer_label: Label = find_child('TimerText')
@onready var timer_icon: TextureRect = find_child('ClockIcon')
@onready var star_label: Label = find_child('StarLabel')

var books_collected: int = 0

func _ready():
	GlobalSignals.star_collected.connect(_on_star_collected)
	GlobalSignals.heart_lost.connect(_on_heart_lost)
	
	if !is_health_visible:
		_hide_health()
	
	if !is_timer_visible:
		_hide_timer()

func _on_star_collected() -> void:
	books_collected += 1
	GameState.stars_collected = books_collected

func _on_heart_lost() -> void:
	var current_hearts = PlayerInventory.get_total_hearts()
	var heart_node = find_child("Heart" + str(current_hearts + 1))
	if heart_node:
		heart_node.queue_free()

func _hide_health() -> void:
	# Find all nodes that start with "Heart" using glob pattern
	var heart_nodes = find_children("Heart*")
	for heart_node in heart_nodes:
		heart_node.queue_free.call_deferred()

func _hide_timer() -> void:
	timer_label.queue_free.call_deferred()
	timer_icon.queue_free.call_deferred()
	
func _process(_delta):
	star_label.text = str(books_collected) + "/" + str(total_books_in_level)

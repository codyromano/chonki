extends PathFollow2D

@export var movement_duration: float = 3.0

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if lever_name != 'wall_near_horse_lever':
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(
		self,
		"progress_ratio",
		1 if is_on else 0, 
		movement_duration
	)
	await tween.finished
	

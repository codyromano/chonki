extends PathFollow2D

@export var movement_duration: float = 15.0

var lever_is_on: bool = false
var lever_change_time: float

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if lever_name == 'elevator_seat_lever':
		lever_is_on = is_on
		lever_change_time = Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !lever_change_time:
		return
		
	var seconds_elapsed = min(movement_duration, Time.get_unix_time_from_system() - lever_change_time)
	var new_progress_ratio = seconds_elapsed / movement_duration
	
	# If the lever is off, then we're going backwards 
	progress_ratio = (1 - new_progress_ratio) if !lever_is_on else new_progress_ratio

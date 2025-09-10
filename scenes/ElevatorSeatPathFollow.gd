extends PathFollow2D

@export var movement_duration: float = 15.0

var lever_is_on: bool = false
var lever_change_time: float
var starting_progress_ratio: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if lever_name == 'elevator_seat_lever':
		# Store the current progress when lever changes
		starting_progress_ratio = progress_ratio
		lever_is_on = is_on
		lever_change_time = Time.get_unix_time_from_system()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !lever_change_time:
		return
		
	var seconds_elapsed = min(movement_duration, Time.get_unix_time_from_system() - lever_change_time)
	
	if lever_is_on:
		# Moving forward: use normal duration
		var movement_progress = seconds_elapsed / movement_duration
		progress_ratio = starting_progress_ratio + movement_progress * (1.0 - starting_progress_ratio)
	else:
		# Moving backward: duration should equal the time it took to get to current position
		# This makes the return trip feel responsive and proportional
		var return_duration = starting_progress_ratio * movement_duration  # Time proportional to distance
		
		if return_duration > 0:
			var movement_progress = min(1.0, seconds_elapsed / return_duration)
			progress_ratio = starting_progress_ratio - movement_progress * starting_progress_ratio
		else:
			progress_ratio = 0.0

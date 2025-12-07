extends Label

signal animation_complete

@export var seconds_per_character: float = 0.02

# This is hacky :(
@onready var pen_sound: AudioStreamPlayer = get_parent().get_parent().get_parent().find_child('PenWritingSound')

@export var text_after_reveal: String
var characters_revealed: int = 0
var start_time: float
var animation_finished: bool = false
var total_animation_duration: float = 0.0
var can_skip: bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if animation_finished:
		return
		
	if !start_time:
		pen_sound.play()
		start_time = Time.get_unix_time_from_system()
		# Calculate total duration based on text length
		total_animation_duration = text_after_reveal.length() * seconds_per_character
	
	var time_elapsed = min(Time.get_unix_time_from_system() - start_time, total_animation_duration)
	var progress_ratio = time_elapsed / total_animation_duration if total_animation_duration > 0 else 1.0
	# Update the characters revealed count
	characters_revealed = ceil(text_after_reveal.length() * progress_ratio)
	
	text = text_after_reveal.substr(0, characters_revealed)
	
	if progress_ratio == 1:
		pen_sound.stop()
		if !animation_finished:
			animation_finished = true
			animation_complete.emit()

func skip_to_end() -> void:
	if !can_skip or animation_finished:
		return
	
	can_skip = false
	animation_finished = true
	characters_revealed = text_after_reveal.length()
	text = text_after_reveal
	
	if !start_time:
		start_time = Time.get_unix_time_from_system()
		total_animation_duration = text_after_reveal.length() * seconds_per_character
	
	if pen_sound:
		pen_sound.stop()
	
	animation_complete.emit()

func is_typing() -> bool:
	return !animation_finished
	

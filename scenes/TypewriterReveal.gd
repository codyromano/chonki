extends Label

@export var animation_duration: float = 3.0
@onready var pen_sound: AudioStreamPlayer = get_parent().get_parent().find_child('PenWritingSound')

@export var text_after_reveal: String
var characters_revealed: int = 0
var start_time: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !start_time:
		pen_sound.play()
		start_time = Time.get_unix_time_from_system()
	
	var time_elapsed = min(Time.get_unix_time_from_system() - start_time, animation_duration)
	var progress_ratio = time_elapsed / animation_duration
	# Update the characters revealed count
	characters_revealed = ceil(text_after_reveal.length() * progress_ratio)
	
	text = text_after_reveal.substr(0, characters_revealed)
	
	if progress_ratio == 1:
		pen_sound.stop()
	

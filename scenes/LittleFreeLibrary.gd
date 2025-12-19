extends Area2D

var is_standing_at_library: bool = false
var can_enter: bool = true
var cooldown_frames: int = 0
		
func _process(_delta):
	if cooldown_frames > 0:
		cooldown_frames -= 1
		if cooldown_frames == 0:
			can_enter = true
			
	$AnimatedSprite2D.play(
		"open" if is_standing_at_library else "default"
	)

func _ready():
	GlobalSignals.on_unload_scene.connect(_on_scene_unloaded)

func _on_scene_unloaded(scene_path: String):
	if scene_path == "res://scenes/little_free_library.tscn":
		can_enter = false
		cooldown_frames = 30

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter' && !GameState.is_anagram_solved(GameState.current_level) && can_enter:
		is_standing_at_library = true
		$AudioStreamPlayer.play()
		
		if body.get_parent().has_method("move_away_from_library"):
			body.get_parent().move_away_from_library()
			await get_tree().process_frame
		
		GlobalSignals.enter_little_free_library.emit()

func _on_body_exited(body):
	if body.name == 'ChonkiCharacter':
		is_standing_at_library = false

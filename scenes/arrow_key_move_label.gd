extends Label

var has_faded_in: bool = false
var is_fading: bool = false

func _ready() -> void:
	modulate.a = 0.0
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dialogue_dismissed)

func _on_dialogue_dismissed(instruction_trigger_id: String) -> void:
	if has_faded_in or is_fading:
		return
	
	has_faded_in = true
	is_fading = true
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	await tween.finished
	is_fading = false

func _input(event: InputEvent) -> void:
	if !has_faded_in or is_fading:
		return
	
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		is_fading = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		await tween.finished
		queue_free()

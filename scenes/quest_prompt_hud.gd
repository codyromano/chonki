extends CanvasLayer

@onready var prompt_label: Label = $Control/Label

var fade_tween: Tween

func _ready():
	GlobalSignals.show_quest_prompt.connect(_on_show_quest_prompt)
	GlobalSignals.hide_quest_prompt.connect(_on_hide_quest_prompt)
	
	if prompt_label:
		prompt_label.modulate.a = 0

func _on_show_quest_prompt():
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.25)

func _on_hide_quest_prompt():
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(prompt_label, "modulate:a", 0.0, 1.0)

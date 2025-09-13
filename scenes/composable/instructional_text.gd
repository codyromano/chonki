extends Control

@export var content: String
@export var id: String
@export var delay_until_fade_in: float = 3.0
@export var fade_in: float = 1.0

@onready var container = $VBoxContainer
var label = find_child('Label')

var faded_in := false
var tween: Tween

func _ready():
	container.modulate.a = 0
	
	GlobalSignals.display_instructional_text.connect(_on_display)
	GlobalSignals.dismiss_instructional_text.connect(_on_dismiss)

func _process(_delta) -> void:
	if _should_dismiss():
		_on_dismiss(id)

func _should_dismiss() -> bool:
	# To be overridden
	return false

func _on_display(instructions_id: String) -> void:
	if !faded_in && id == instructions_id:
		label.text = content
		faded_in = true
		tween = create_tween()
		tween.tween_property(container, "modulate:a", 1.0, fade_in)
		await tween.finished
	
func _on_dismiss(instructions_id: String) -> void:
	if instructions_id == id and faded_in:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(container, "modulate:a", 0.0, fade_in)
		tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	queue_free.call_deferred()

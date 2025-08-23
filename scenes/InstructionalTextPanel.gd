extends Panel

@export_enum(
	"MoveLeftOrRight",
) var id: String = "MoveLeftOrRight"
@export var delay_until_fade_in: float = 3.0
@export var fade_in: float = 1.0

var timer := 0.0
var faded_in := false
var tween: Tween
var alpha := 0.0

func _ready():
	alpha = 0.0
	self.modulate.a = alpha
	timer = 0.0
	faded_in = false
	tween = null
	GlobalSignals.dismiss_instructional_text.connect(_on_dismiss)

func _on_dismiss(instructions_id: String) -> void:
	if instructions_id == id and faded_in:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "alpha", 0.0, fade_in)
		tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	self.visible = false
	
func _process(delta):
	self.modulate.a = alpha
	if faded_in:
		return
	timer += delta
	if timer >= delay_until_fade_in:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "alpha", 1.0, fade_in)
		tween.finished.connect(_on_fade_in_finished)
		faded_in = true

func _on_fade_in_finished():
	# Fade-in complete
	pass

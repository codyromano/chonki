extends PanelContainer

@export var dialogue: String = "Hello, world"
@export var duration: float = 3.0

func _ready():
	$TypewriterReveal.text_after_reveal = dialogue
	$TypewriterReveal.animation_duration = duration

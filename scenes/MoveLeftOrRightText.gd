extends "res://scenes/InstructionalTextPanel.gd"

var is_dismissed: bool = false

func _ready() -> void:
	super._ready()

func _process(delta):
	super._process(delta)
	if !is_dismissed && (Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_right")):
		print("dismiss signal should fire")
		GlobalSignals.dismiss_instructional_text.emit("MoveLeftOrRight")
		is_dismissed = true

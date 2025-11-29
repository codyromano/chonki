extends Area2D

@export var sign_name: String

@onready var label: Label = find_child('EnterLabel')

const FADE_SPEED = 0.25

var is_standing_by_sign: bool = false

func _ready() -> void:
	if !sign_name:
		push_error("Warning sign has unspecified name")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		GlobalSignals.enter_warning_sign.emit(sign_name)

func _on_body_entered(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_standing_by_sign = true
		
		# Fade in the instructional text 
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1, FADE_SPEED)
		await tween.finished 
	else:
		print("Warning sign collided with non-player body")


func _on_body_exited(body: Node2D) -> void:
	if body.name == 'ChonkiCharacter':
		is_standing_by_sign = false
		
		# Fade out the instructional text 
		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 0, FADE_SPEED)
		await tween.finished 
	else:
		print("Non-player body exited warning sign")

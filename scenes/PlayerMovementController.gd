extends Node2D

## PlayerMovementController
##
## Responsible for listening to UI input actions and broadcasting 
## movement-related signals to decouple input handling from player logic.
## 
## Note: Environmental interactions (like trampolines) emit the same signals
## directly through GlobalSignals rather than going through this controller.

func _ready():
	# This controller should be added to the scene tree early
	# to capture input events and broadcast them via signals
	pass

func _process(_delta):
	if MainDialogueController.rendered_dialogue != null:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		var jump_intensity = 1.0
		GlobalSignals.player_jump.emit(jump_intensity, "player")

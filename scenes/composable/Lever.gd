extends Area2D

@export var timer_duration: float = 5.0
@export var is_on_initially: bool = false
@export var lever_name: String

var is_on: bool = is_on_initially

func _ready() -> void:
	$Timer.wait_time = timer_duration

func _process(_delta):
	$LeverSprite.play("on" if is_on else "default")
	
	if is_on && !$LeverTick.playing:
		$Timer.start()
		$LeverTick.play()
	elif !is_on:
		$Timer.stop()
		$LeverTick.stop()

func _on_body_entered(_body):
	$LeverPull.play()
	
	is_on = !is_on
	GlobalSignals.lever_status_changed.emit(lever_name, is_on)
	
func _on_timer_timeout():
	$LeverPull.play()
	is_on = false
	GlobalSignals.lever_status_changed.emit(lever_name, is_on)

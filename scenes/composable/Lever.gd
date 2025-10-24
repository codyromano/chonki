extends Area2D

@export var timer_duration: float = 5.0
@export var is_on: bool = false
@export var lever_name: String
@export var touchable_while_timer_is_active: bool = true

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

func _on_body_entered(body):
	if body.name == 'ChonkiCharacter':
		# Check if lever is touchable while timer is active
		if !touchable_while_timer_is_active && !$Timer.is_stopped():
			return
		
		$LeverPull.play()
	
		is_on = !is_on
		GlobalSignals.lever_status_changed.emit(lever_name, is_on)
	
func _on_timer_timeout():
	$LeverPull.play()
	is_on = false
	GlobalSignals.lever_status_changed.emit(lever_name, is_on)

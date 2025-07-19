extends Area2D

var is_entered: bool = false

func _on_body_entered(_body):
	if !is_entered:
		GlobalSignals.crow_dropped_branch.emit()
		is_entered = true

func _on_body_exited(_body):
	is_entered = false

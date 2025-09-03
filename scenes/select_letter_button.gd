extends Button

@export var id: String
@export var data: String

func _ready() -> void:
	text = data

func _on_button_down() -> void:
	GlobalSignals.on_data_button_selected.emit(id, data)
	queue_free.call_deferred()

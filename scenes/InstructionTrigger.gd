extends Area2D

@export var id: String
@export var dialogue: String

var _times_triggered: int = 0

# Override for instance-specific effects
func _on_triggered(_trigger_times: int) -> void:
	pass

# Override this method to add custom behavior after dialogue is dismissed
func on_after_dismiss_dialogue() -> void:
	pass

# Called when dialogue is dismissed - handles cleanup and calls override method
func after_dismiss_dialogue() -> void:
	# Call the overridable method first
	on_after_dismiss_dialogue()
	# Then handle cleanup
	queue_free.call_deferred()

func _ready() -> void:
	# Connect to the dismiss signal to know when our dialogue is dismissed
	GlobalSignals.dismiss_active_main_dialogue.connect(_on_dialogue_dismissed)

func _on_dialogue_dismissed(instruction_trigger_id: String) -> void:
	# Only respond if this is our dialogue being dismissed and we're still in the tree
	if is_inside_tree() and instruction_trigger_id == id:
		after_dismiss_dialogue()

func _on_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == 'ChonkiCharacter':
		GlobalSignals.queue_main_dialogue.emit(dialogue, id)
		
		_times_triggered += 1
		_on_triggered(_times_triggered)

extends "res://scenes/InstructionTrigger.gd"

# Override to emit the enter_little_free_library signal when dialogue is dismissed
func on_after_dismiss_dialogue() -> void:
	GlobalSignals.enter_little_free_library.emit()
	self.queue_free.call_deferred()

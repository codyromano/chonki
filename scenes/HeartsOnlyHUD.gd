extends CanvasLayer

func _ready():
	GlobalSignals.heart_lost.connect(_on_heart_lost)

func _on_heart_lost() -> void:
	var current_hearts = PlayerInventory.get_total_hearts()
	var heart_node = find_child("Heart" + str(current_hearts + 1))
	if heart_node:
		heart_node.queue_free()

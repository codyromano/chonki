extends Control

const INITIAL_HEARTS_TOTAL = 3
var total_hearts: int = 3

func _ready():
	GlobalSignals.heart_lost.connect(_on_heart_collected)

func _on_heart_collected() -> void:
	total_hearts = max(total_hearts - 1, 0)
	
	var heart_nodes = get_children().filter(
		func (n):
			return n.name.begins_with('Heart')
	)
	for i in range(0, heart_nodes.size()):
		heart_nodes[i].visible = i < total_hearts

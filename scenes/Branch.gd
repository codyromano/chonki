extends Sprite2D

func _ready():
	GlobalSignals.crow_dropped_branch.connect(_on_crow_dropped_branch)

func _on_crow_dropped_branch():
	print("crow dropped branch signal")

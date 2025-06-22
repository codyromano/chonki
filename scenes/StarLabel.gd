extends Label

var total_collected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSignals.star_collected.connect(_on_star_collected)

func _on_star_collected() -> void:
	total_collected+= 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = str(total_collected)

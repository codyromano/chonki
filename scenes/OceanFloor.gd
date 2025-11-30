extends StaticBody2D

@onready var damage_area: Area2D = $OceanFloorDamageArea

func _ready():
	if damage_area:
		damage_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		# Ocean floor contact removes all three hearts
		GlobalSignals.player_hit.emit("ocean")
		GlobalSignals.player_hit.emit("ocean")
		GlobalSignals.player_hit.emit("ocean")

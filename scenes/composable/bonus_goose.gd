extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "ChonkiCharacter":
		GlobalSignals.player_hit.emit("bonus_goose")

extends CharacterBody2D

func on_item_collected(_item_name: String) -> void:
	GlobalSignals.star_collected.emit()
	
func is_attacking() -> bool:
	return $AnimatedSprite2D.animation in ["ram", "push"]

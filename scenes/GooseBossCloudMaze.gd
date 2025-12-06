extends Area2D

enum GooseState {
	DEFEATED
}

var states: Dictionary = {}
var defeat_triggered: bool = false

@onready var sprite := $AnimatedSprite2D
@onready var collision_shape := $CollisionShape2D

func _ready():
	if sprite:
		sprite.play()
	body_entered.connect(_on_body_entered)

func trigger_defeat() -> void:
	if defeat_triggered:
		return
	
	defeat_triggered = true
	states[GooseState.DEFEATED] = true
	
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	
	if has_node("GooseDefeated"):
		$GooseDefeated.play()
	
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 3.0)
	
	await fade_tween.finished
	queue_free()

func _process(delta: float) -> void:
	if not sprite:
		return
		
	if states.has(GooseState.DEFEATED):
		position.y -= 800.0 * delta
		sprite.play("hurt")
	else:
		sprite.play("default")

func _on_body_entered(body: Node) -> void:
	if states.has(GooseState.DEFEATED):
		return
		
	if body.name == "ChonkiCharacter":
		if "is_attacking" in body:
			if body.is_attacking():
				Utils.throttle('goose_cloud_maze_hit', func():
					if has_node("GooseDefeated"):
						$GooseDefeated.play()
					trigger_defeat()
				, 2)
			else:
				Utils.throttle('player_hit_boss_cloud_maze', func():
					GlobalSignals.player_hit.emit("goose_boss")
					GlobalSignals.player_hit.emit("goose_boss")
					GlobalSignals.player_hit.emit("goose_boss")
				, 3)

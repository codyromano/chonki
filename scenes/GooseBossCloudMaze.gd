extends CharacterBody2D

enum GooseState {
	DEFEATED
}

var states: Dictionary = {}
var defeat_triggered: bool = false

@onready var sprite := $AnimatedSprite2D

func _ready():
	if sprite:
		sprite.play()

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

func _physics_process(delta: float) -> void:
	if not sprite:
		return
		
	if states.has(GooseState.DEFEATED):
		velocity.y = -800.0
		velocity.x = 0.0
		position += velocity * delta
		sprite.play("hurt")
	else:
		sprite.play("default")

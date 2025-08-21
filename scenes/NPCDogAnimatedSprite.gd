# Determines the current sprite for the NPC dog
extends AnimatedSprite2D

@onready var character_body: CharacterBody2D = get_parent()
var last_movement_time: int = 0

func _process(_delta) -> void:
	last_movement_time = character_body.last_movement_time

func get_run_sprite() -> String:
	if character_body.velocity.x != 0:
		return "run"
	return ""

func get_jump_sprite() -> String:
	if not character_body.is_on_floor:
		return "jump"
	return ""

func get_sleep_sprite() -> String:
	var secs_since_action = Time.get_unix_time_from_system() - last_movement_time
	if secs_since_action >= 15:
		return "sleep"
	return ""

func get_rest_sprite() -> String:
	var secs_since_action = Time.get_unix_time_from_system() - last_movement_time
	if secs_since_action >= AnimationConstants.TIME_UNTIL_REST:
		return "rest"
	return ""

func get_idle_sprite() -> String:
	return "idle"

func handle_sprite_flip() -> void:
	var x_velocity = character_body.velocity.x 
	
	if x_velocity > 0:
		flip_h = true
	elif x_velocity < 0:
		flip_h = false

func update_sprite() -> void:
	var possible_next_sprites = [
		get_jump_sprite(),
		get_run_sprite(),
		get_sleep_sprite(),
		get_rest_sprite(),
		get_idle_sprite()
	]

	for next_sprite in possible_next_sprites:
		if next_sprite != "":
			if animation != next_sprite:
				play(next_sprite)
			handle_sprite_flip()
			return

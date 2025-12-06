extends Area2D

@onready var arrow_left: Label = $ArrowLeft
@onready var arrow_right: Label = $ArrowRight
@onready var arrow_up: Label = $ArrowUp
@onready var arrow_down: Label = $ArrowDown

var direction_horizontal: int = -1
var direction_vertical: int = -1
var is_powered: bool = false
var is_returning: bool = false
var power_start_time: float = 0.0
var initial_position: Vector2
var goose_defeated: bool = false

var arrow_tweens: Dictionary = {}

const POWER_DURATION: float = 12.0
const RETURN_DURATION: float = 4.0

func _ready() -> void:
	initial_position = position
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)
	area_entered.connect(_on_area_entered)
	_update_arrow_display()

func _process(delta: float) -> void:
	if is_powered:
		var elapsed = Time.get_unix_time_from_system() - power_start_time
		
		if elapsed < POWER_DURATION:
			var direction = Vector2(direction_horizontal, direction_vertical).normalized()
			var velocity = direction * (PhysicsConstants.SPEED / 3.0)
			position += velocity * delta
			_check_collision_backup()
		else:
			_start_return()
	
func _start_return() -> void:
	is_powered = false
	is_returning = true
	
	var return_tween = create_tween()
	return_tween.tween_property(self, "position", initial_position, RETURN_DURATION)
	await return_tween.finished
	is_returning = false

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if lever_name == "CloudLeverPower":
		if is_on and not is_returning:
			is_powered = true
			power_start_time = Time.get_unix_time_from_system()
	elif lever_name == "CloudLeverLeftOrRight":
		if not is_returning and is_on:
			direction_horizontal = -direction_horizontal
			_update_arrow_display()
	elif lever_name == "CloudLeverUpOrDown":
		if not is_returning and is_on:
			direction_vertical = -direction_vertical
			_update_arrow_display()

func _update_arrow_display() -> void:
	arrow_left.visible = direction_horizontal == -1
	arrow_right.visible = direction_horizontal == 1
	arrow_up.visible = direction_vertical == -1
	arrow_down.visible = direction_vertical == 1
	
	_stop_arrow_tween(arrow_left)
	_stop_arrow_tween(arrow_right)
	_stop_arrow_tween(arrow_up)
	_stop_arrow_tween(arrow_down)
	
	if arrow_left.visible:
		_start_arrow_pulse(arrow_left)
	if arrow_right.visible:
		_start_arrow_pulse(arrow_right)
	if arrow_up.visible:
		_start_arrow_pulse(arrow_up)
	if arrow_down.visible:
		_start_arrow_pulse(arrow_down)

func _start_arrow_pulse(arrow: Label) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(arrow, "scale", Vector2(1.1, 1.1), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(arrow, "scale", Vector2(0.9, 0.9), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	arrow_tweens[arrow] = tween

func _stop_arrow_tween(arrow: Label) -> void:
	if arrow_tweens.has(arrow) and arrow_tweens[arrow]:
		arrow_tweens[arrow].kill()
		arrow.scale = Vector2(1.0, 1.0)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "GooseBossCloudMaze" and not goose_defeated:
		goose_defeated = true
		if area.has_method("trigger_defeat"):
			area.trigger_defeat()

func _check_collision_backup() -> void:
	if goose_defeated:
		return
	
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area.name == "GooseBossCloudMaze":
			goose_defeated = true
			if area.has_method("trigger_defeat"):
				area.trigger_defeat()
			break

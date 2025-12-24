extends Node

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var label1: Label = $VBoxContainer/Label
@onready var label2: Label = $VBoxContainer/Label2
@onready var label3: Label = $VBoxContainer/Label3

var words_added: Array[String] = []
var lever_words: Dictionary = {
	"CloudLeverPower": "goose!",
	"CloudLeverLeftOrRight": "large",
	"CloudLeverUpOrDown": "move"
}
var lever_states: Dictionary = {}

var win_audio: AudioStreamPlayer
var goose_boss: Area2D

func _ready() -> void:
	GlobalSignals.lever_status_changed.connect(_on_lever_changed)
	_reset_sign()
	
	win_audio = AudioStreamPlayer.new()
	win_audio.stream = preload("res://assets/sound/anagram-win.mp3")
	add_child(win_audio)
	
	goose_boss = get_tree().current_scene.find_child("GooseBossCloudMaze", true, false)

func _reset_sign() -> void:
	label1.text = "Hack"
	label2.text = "this"
	label3.text = "sign?"
	words_added.clear()

func _clear_sign() -> void:
	label1.text = ""
	label2.text = ""
	label3.text = ""

func _on_lever_changed(lever_name: String, is_on: bool) -> void:
	if not lever_words.has(lever_name):
		return
	
	var was_on = lever_states.get(lever_name, false)
	lever_states[lever_name] = is_on
	
	if was_on and not is_on:
		if not words_added.is_empty():
			_reset_sign()
			_reset_levers()
		return
	
	if not is_on:
		return
	
	var word = lever_words[lever_name]
	
	if word in words_added:
		return
	
	if words_added.is_empty():
		_clear_sign()
	
	words_added.append(word)
	_update_display()
	
	if words_added.size() == 3:
		_check_solution()

func _update_display() -> void:
	var labels = [label1, label2, label3]
	for i in range(words_added.size()):
		labels[i].text = words_added[i]

func _check_solution() -> void:
	var phrase = " ".join(words_added)
	
	if phrase == "move large goose!":
		win_audio.play()
		
		if goose_boss and goose_boss.has_method("trigger_defeat"):
			goose_boss.trigger_defeat()
		
		await _fade_out_and_cleanup()
	else:
		await get_tree().create_timer(1.0).timeout
		_reset_sign()
		_reset_levers()

func _reset_levers() -> void:
	var cloud_maze = get_parent()
	if not cloud_maze:
		return
	
	for lever_name in lever_words.keys():
		var lever = cloud_maze.find_child(lever_name, true, false)
		if lever:
			lever.is_on = false
			if lever.has_node("Timer"):
				lever.get_node("Timer").stop()
			GlobalSignals.lever_status_changed.emit(lever_name, false)

func _fade_out_and_cleanup() -> void:
	var cloud_maze = get_parent()
	if not cloud_maze:
		return
	
	var levers_to_fade: Array[Node] = []
	for lever_name in lever_words.keys():
		var lever = cloud_maze.find_child(lever_name, true, false)
		if lever:
			levers_to_fade.append(lever)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(vbox, "modulate:a", 0.0, 2.0)
	
	for lever in levers_to_fade:
		tween.tween_property(lever, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	
	for lever in levers_to_fade:
		lever.queue_free()
	
	queue_free()

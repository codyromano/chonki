extends CharacterBody2D

@onready var world: Node2D = get_node('%World2D')
@onready var branch_scene: PackedScene = preload("res://scenes/branch.tscn")

func _ready() -> void:
	_spawn_branch.call_deferred()
	GlobalSignals.biker_cleaned_up_branch.connect(_spawn_branch)

func _process(_delta) -> void:
	pass

func _spawn_branch() -> void:
	var branch_marker: Marker2D = find_child('BranchMarker')
	var branch: CharacterBody2D = branch_scene.instantiate()
	branch.name = "Branch"
	branch.target_marker = branch_marker
	
	world.add_child(branch)

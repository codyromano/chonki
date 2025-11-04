extends Node2D

@onready var leaf_system = find_child('Leaves')

var total_secret_letters: int = 0
var collected_secret_letters: int = 0
var letters_display_label: Label
var letters_display_control: Control

func _ready():
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	_count_total_secret_letters()
	_create_letters_display()
	
func _count_total_secret_letters():
	total_secret_letters = 0
	
	var letters_node = get_node_or_null("Letters")
	if letters_node:
		for child in letters_node.get_children():
			if child.name.begins_with("SecretLetter"):
				total_secret_letters += 1
	
	if total_secret_letters == 0:
		var secret_letters = get_tree().get_nodes_in_group("secret_letters")
		total_secret_letters = secret_letters.size()
	
	if total_secret_letters == 0:
		total_secret_letters = _count_secret_letters_recursive(self)

func _count_secret_letters_recursive(node: Node) -> int:
	var count = 0
	
	if node.get_script() and node.get_script().get_path().ends_with("SecretLetter.gd"):
		count += 1
	
	for child in node.get_children():
		count += _count_secret_letters_recursive(child)
	
	return count

func _create_letters_display():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 5
	add_child(canvas_layer)
	
	letters_display_control = Control.new()
	letters_display_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	letters_display_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	letters_display_control.modulate.a = 0.0
	canvas_layer.add_child(letters_display_control)
	
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	letters_display_control.add_child(center_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_container.add_child(vbox)
	
	var title_label = Label.new()
	title_label.text = "Double-jump unlocked"
	title_label.add_theme_font_size_override("font_size", 120)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	title_label.add_theme_constant_override("outline_size", 8)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_label)
	
	letters_display_label = Label.new()
	letters_display_label.text = "Level 0/%d" % total_secret_letters
	letters_display_label.add_theme_font_size_override("font_size", 150)
	letters_display_label.add_theme_color_override("font_color", Color.WHITE)
	letters_display_label.add_theme_constant_override("outline_size", 8)
	letters_display_label.add_theme_color_override("font_outline_color", Color.BLACK)
	letters_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letters_display_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(letters_display_label)

func _on_secret_letter_collected(_letter: String):
	if not letters_display_control:
		return
	
	collected_secret_letters += 1
	letters_display_label.text = "Level %d/%d" % [collected_secret_letters, total_secret_letters]
	
	var tween = create_tween()
	
	tween.tween_property(letters_display_control, "modulate:a", 1.0, 0.5)
	
	tween.tween_interval(5.0)
	
	tween.tween_property(letters_display_control, "modulate:a", 0.0, 0.5)

func _on_wind_change():
	pass

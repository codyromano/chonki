extends Node2D

@onready var leaf_system = find_child('Leaves')
@onready var sniglet_font: Font = preload("res://fonts/Sniglet-Regular.ttf")

var letters_display_label: Label
var letters_display_control: Control
var title_label: Label
var subtitle_label: Label

func _ready():
	GameState.current_level = 2
	GlobalSignals.secret_letter_collected.connect(_on_secret_letter_collected)
	
	GameState.restore_letters_from_persistent_state(2)
	
	_create_letters_display()
	_create_jump_height_indicator()
	
	if title_label:
		var collected = PlayerInventory.get_collected_secret_letter_count()
		if collected > 0:
			title_label.text = "Jump power: %d / 5" % collected

func _create_jump_height_indicator():
	var indicator = ColorRect.new()
	indicator.name = "JumpHeightIndicator"
	indicator.color = Color.YELLOW
	var jump_height = 2500.0
	indicator.size = Vector2(20, jump_height)
	indicator.position = Vector2(1000, 1000 - jump_height)
	add_child(indicator)

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
	
	title_label = Label.new()
	title_label.text = "Jump power: 0 / 5"
	title_label.add_theme_font_override("font", sniglet_font)
	title_label.add_theme_font_size_override("font_size", 125)
	title_label.add_theme_color_override("font_color", Color(1, 1, 0.529412, 1))
	title_label.add_theme_constant_override("outline_size", 20)
	title_label.add_theme_color_override("font_outline_color", Color.BLACK)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_label)
	
	subtitle_label = Label.new()
	subtitle_label.text = "Each letter you collect lets you perform one extra mid-air jump"
	subtitle_label.add_theme_font_override("font", sniglet_font)
	subtitle_label.add_theme_font_size_override("font_size", 30)
	subtitle_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	subtitle_label.add_theme_constant_override("outline_size", 20)
	subtitle_label.add_theme_color_override("font_outline_color", Color.BLACK)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(subtitle_label)
	
	letters_display_label = Label.new()
	letters_display_label.text = ""
	letters_display_label.add_theme_font_override("font", sniglet_font)
	letters_display_label.add_theme_font_size_override("font_size", 150)
	letters_display_label.add_theme_color_override("font_color", Color(1, 1, 0.529412, 1))
	letters_display_label.add_theme_constant_override("outline_size", 20)
	letters_display_label.add_theme_color_override("font_outline_color", Color.BLACK)
	letters_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letters_display_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(letters_display_label)

func _on_secret_letter_collected(_letter_item: PlayerInventory.Item):
	if not letters_display_control:
		return
	
	var collected = PlayerInventory.get_collected_secret_letter_count()
	
	# Update title with current jump power
	if title_label:
		title_label.text = "Jump power: %d / 5" % collected
	
	var tween = create_tween()
	
	tween.tween_property(letters_display_control, "modulate:a", 1.0, 0.5)
	
	tween.tween_interval(5.0)
	
	tween.tween_property(letters_display_control, "modulate:a", 0.0, 0.5)

func _on_wind_change():
	pass

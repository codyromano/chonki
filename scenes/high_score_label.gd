extends Label

func _ready() -> void:
	add_theme_font_override("font", ThemeDB.fallback_font)
	update_high_score()
	hide_high_score_hud()
	GlobalSignals.collected_jetpack.connect(_on_jetpack_collected)

func _on_jetpack_collected() -> void:
	show_high_score_hud()

func hide_high_score_hud() -> void:
	var hud = get_tree().current_scene.get_node_or_null("HighScoreHUD")
	if hud:
		hud.visible = false

func show_high_score_hud() -> void:
	var hud = get_tree().current_scene.get_node_or_null("HighScoreHUD")
	if hud:
		hud.visible = true

func _process(_delta: float) -> void:
	update_high_score()

func update_high_score() -> void:
	text = format_number(GameState.bonus_high_score)

func format_number(num: int) -> String:
	var abbreviated_num = round(num / 10)
	var str_num = str(abbreviated_num)
	var formatted = ""
	var count = 0
	
	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_num[i] + formatted
		count += 1
	
	return formatted

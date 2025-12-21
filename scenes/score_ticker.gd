extends Label

var score: int = 0
var max_score: int = 0
@export var chonki: Node2D

func _ready() -> void:
	add_theme_font_override("font", ThemeDB.fallback_font)
	text = format_number(0)
	chonki = chonki.find_child('ChonkiCharacter')

func _process(delta: float) -> void:
	if chonki and not chonki.is_on_floor():
		var current_height = int(abs(chonki.global_position.y))
		if current_height > max_score:
			max_score = current_height
		score = max_score
		
	text = format_number(score)

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

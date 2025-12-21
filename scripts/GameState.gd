extends Node


# Singleton to persist gameplay data between scenes
var current_level: int = 1
var stars_collected: int = 0
var total_stars: int = 0
var time_elapsed: float = 0.0
var puzzle_solution_by_scene: Dictionary = {
	1: "adopt",
	2: "fresh"
}
var letters_collected_by_scene: Dictionary = {
  1: [],
  2: [],
}

var triggered_instruction_triggers: Dictionary = {}

var anagrams_solved_by_level: Dictionary = {}

var bonus_high_score: int = 0

# Cache for total stars per level (by scene path)
var stars_per_level := {}

# Track collected collectibles by level for respawn persistence
var collected_star_ids_by_level: Dictionary = {}
var collected_letter_items_by_level: Dictionary = {}
var stars_before_respawn: int = 0

# Track quest states by level for respawn persistence
var quest_states_by_level: Dictionary = {}

func _ready():
	collected_star_ids_by_level = {1: [], 2: []}
	collected_letter_items_by_level = {1: [], 2: []}
	quest_states_by_level = {
		1: {},
		2: {
			"ruby_volleyball_returned": false,
			"ruby_reward_given": false,
			"isaac_eagle_returned": false,
			"isaac_reward_given": false,
			"isaac_has_met": false,
			"momo_quest_accepted": false,
			"momo_reward_given": false
		}
	}

# Static dictionary for time thresholds per level (by scene path)
const TIME_THRESHOLDS_PER_LEVEL = {
	"res://scenes/level1.tscn": {"perfect": 20, "great": 80, "okay": 90},
	# Add more levels here as needed
}

# Default thresholds (used if not specified above)
const DEFAULT_THRESHOLDS = {
	"perfect": 60,
	"great": 80,
	"okay": 90
}

func reset():
	stars_collected = 0
	time_elapsed = 0.0

# Call this at level start to set and cache total stars for the current level
# Call this at level start to set and cache total stars for the current level
func set_total_stars_for_level(level_path: String, count: int):
	stars_per_level[level_path] = count
	total_stars = count

# Get time thresholds for the current level, falling back to defaults
func get_time_thresholds_for_level(level_path: String) -> Dictionary:
	if TIME_THRESHOLDS_PER_LEVEL.has(level_path):
		return TIME_THRESHOLDS_PER_LEVEL[level_path]
	return DEFAULT_THRESHOLDS.duplicate()

# Call this at level start to load cached total stars if available
func get_total_stars_for_level(level_path: String) -> int:
	if stars_per_level.has(level_path):
		total_stars = stars_per_level[level_path]
		return total_stars
	return 0

func add_collected_letter(letter: String) -> void:
	letters_collected_by_scene[current_level].append(letter)

func get_collected_letters() -> Array:
	return letters_collected_by_scene[current_level]

func get_letter_string_from_item(item: PlayerInventory.Item) -> String:
	match item:
		PlayerInventory.Item.SECRET_LETTER_A:
			return "A"
		PlayerInventory.Item.SECRET_LETTER_D:
			return "D"
		PlayerInventory.Item.SECRET_LETTER_O:
			return "O"
		PlayerInventory.Item.SECRET_LETTER_P:
			return "P"
		PlayerInventory.Item.SECRET_LETTER_T:
			return "T"
		PlayerInventory.Item.SECRET_LETTER_F:
			return "F"
		PlayerInventory.Item.SECRET_LETTER_R:
			return "R"
		PlayerInventory.Item.SECRET_LETTER_E:
			return "E"
		PlayerInventory.Item.SECRET_LETTER_S:
			return "S"
		PlayerInventory.Item.SECRET_LETTER_H:
			return "H"
		_:
			return ""

func restore_letters_from_persistent_state(level: int) -> void:
	if !letters_collected_by_scene.has(level):
		letters_collected_by_scene[level] = []
	
	if collected_letter_items_by_level.has(level):
		for item in collected_letter_items_by_level[level]:
			var letter_str = get_letter_string_from_item(item)
			if letter_str != "" and letter_str not in letters_collected_by_scene[level]:
				letters_collected_by_scene[level].append(letter_str)

func get_current_level_puzzle_solution() -> String:
	var solution = puzzle_solution_by_scene[current_level]
	return solution

func is_instruction_trigger_used(trigger_id: String) -> bool:
	return triggered_instruction_triggers.get(trigger_id, false)

func mark_instruction_trigger_used(trigger_id: String) -> void:
	triggered_instruction_triggers[trigger_id] = true

func mark_anagram_solved(level: int) -> void:
	anagrams_solved_by_level[level] = true

func is_anagram_solved(level: int) -> bool:
	return anagrams_solved_by_level.get(level, false)

func update_bonus_high_score(new_score: int) -> void:
	if new_score > bonus_high_score:
		bonus_high_score = new_score

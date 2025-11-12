extends Node


# Singleton to persist gameplay data between scenes
var current_level: int = 1
var stars_collected: int = 0
var total_stars: int = 0
var time_elapsed: float = 0.0
var puzzle_solution_by_scene: Dictionary = {
	1: "adopt",
	2: "relax"
}
var letters_collected_by_scene: Dictionary = {
  1: [],
  2: [],
}

# Cache for total stars per level (by scene path)
var stars_per_level := {}

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
	print("[GameState] Adding letter '", letter, "' to level ", current_level)
	letters_collected_by_scene[current_level].append(letter)
	print("[GameState] Total letters collected for level ", current_level, ": ", letters_collected_by_scene[current_level])

func get_collected_letters() -> Array:
	print("[GameState] Getting collected letters for level ", current_level, ": ", letters_collected_by_scene[current_level])
	return letters_collected_by_scene[current_level]

func get_current_level_puzzle_solution() -> String:
	var solution = puzzle_solution_by_scene[current_level]
	print("[GameState] Puzzle solution for level ", current_level, ": '", solution, "'")
	return solution

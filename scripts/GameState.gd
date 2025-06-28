extends Node


# Singleton to persist gameplay data between scenes
var stars_collected: int = 0
var total_stars: int = 0
var time_elapsed: float = 0.0
# Cache for total stars per level (by scene path)
var stars_per_level := {}

func reset():
	stars_collected = 0
	time_elapsed = 0.0

# Call this at level start to set and cache total stars for the current level
func set_total_stars_for_level(level_path: String, count: int):
	stars_per_level[level_path] = count
	total_stars = count

# Call this at level start to load cached total stars if available
func get_total_stars_for_level(level_path: String) -> int:
	if stars_per_level.has(level_path):
		total_stars = stars_per_level[level_path]
		return total_stars
	return 0

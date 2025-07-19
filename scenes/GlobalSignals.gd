extends Node
class_name Signals

# Causes player to lose one life
signal player_hit
signal star_collected
signal heart_lost
signal win_game
signal time_up
signal player_out_of_hearts
signal animate_camera_zoom_level  # Signal to trigger camera zoom animation (e.g., after colliding with cherry tree)
signal crow_dropped_branch  # Signal emitted when the player collides with the crow and the crow drops a branch

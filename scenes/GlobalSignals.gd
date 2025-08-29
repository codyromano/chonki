extends Node

# Causes player to lose one life
signal player_hit
signal star_collected
signal heart_lost
signal win_game
signal time_up
signal player_out_of_hearts
signal animate_camera_zoom_level
signal game_zoom_level(zoom_level: float, zoom_duration: float)
signal crow_dropped_branch
signal biker_hit_branch
signal biker_cleaned_up_branch
signal chonki_touched_kite(Vector2, int)
signal kite_rotated(Vector2, int, float)
signal chonki_slide_status(bool)
signal spawn_hearts_begin
signal chonki_state_updated(velocity, is_on_floor, is_chonki_sliding, can_slide_on_release, last_action_time, time_held, state)
signal play_sfx(sound_name)
signal stop_sfx(sound_name)
signal slide_start
signal slide_end
signal dismiss_instructional_text(instructions_id: String)
signal display_instructional_text(instructions_id: String)
signal lever_status_changed(lever_name: String, is_on: bool)

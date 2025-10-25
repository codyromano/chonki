extends Node

# Causes player to lose one life
@warning_ignore("unused_signal")
signal player_hit
@warning_ignore("unused_signal")
signal star_collected
@warning_ignore("unused_signal")
signal heart_lost
@warning_ignore("unused_signal")
signal win_game(zoom_intensity: float)
@warning_ignore("unused_signal")
signal time_up
@warning_ignore("unused_signal")
signal player_out_of_hearts
@warning_ignore("unused_signal")
signal animate_camera_zoom_level
@warning_ignore("unused_signal")
signal game_zoom_level(zoom_level: float, zoom_duration: float)
@warning_ignore("unused_signal")
signal crow_dropped_branch
@warning_ignore("unused_signal")
signal biker_hit_branch
@warning_ignore("unused_signal")
signal biker_cleaned_up_branch
@warning_ignore("unused_signal")
signal chonki_touched_kite(Vector2, int)
@warning_ignore("unused_signal")
signal kite_rotated(Vector2, int, float)
@warning_ignore("unused_signal")
signal chonki_slide_status(bool)
@warning_ignore("unused_signal")
signal spawn_hearts_begin
@warning_ignore("unused_signal")
signal chonki_landed_and_hearts_spawned
@warning_ignore("unused_signal")
signal chonki_state_updated(velocity, is_on_floor, is_chonki_sliding, can_slide_on_release, last_action_time, time_held, state)
@warning_ignore("unused_signal")
signal play_sfx(sound_name)
@warning_ignore("unused_signal")
signal stop_sfx(sound_name)
@warning_ignore("unused_signal")
signal slide_start
@warning_ignore("unused_signal")
signal slide_end
@warning_ignore("unused_signal")
signal dismiss_instructional_text(instructions_id: String)
@warning_ignore("unused_signal")
signal display_instructional_text(instructions_id: String)
@warning_ignore("unused_signal")
signal lever_status_changed(lever_name: String, is_on: bool)
@warning_ignore("unused_signal")
signal player_jump(intensity: float, entity_applying_force: String)
@warning_ignore("unused_signal")
signal horse_buck
@warning_ignore("unused_signal")
signal enter_little_free_library
@warning_ignore("unused_signal")
signal on_data_button_selected(button_id: String, data: String)
@warning_ignore("unused_signal")
signal dismiss_active_main_dialogue(instruction_trigger_id: String)
@warning_ignore("unused_signal")
signal queue_main_dialogue(dialogue_id: String, instruction_trigger_id: String, avatar_name: String, choices: Array)
@warning_ignore("unused_signal")
signal set_dialogue_options(choices: Array)
@warning_ignore("unused_signal")
signal dialogue_option_selected(option_id: String, option_text: String)
@warning_ignore("unused_signal")
signal internal_force_display_main_dialogue(dialogue_id: String)
@warning_ignore("unused_signal")
signal press_reset_anagram()
@warning_ignore("unused_signal")
signal anagram_word_guess_updated(word: String)
@warning_ignore("unused_signal")
signal player_registered(player: Node2D)
@warning_ignore("unused_signal")
signal player_unregistered
@warning_ignore("unused_signal")
signal secret_letter_collected(letter: String)
@warning_ignore("unused_signal")
signal backflip_triggered()
@warning_ignore("unused_signal")
signal set_chonki_frozen(is_frozen: bool)
@warning_ignore("unused_signal")
signal unlock_ruby_quest_reward()
@warning_ignore("unused_signal")
signal spawn_item_in_location(item_name: PlayerInventory.Item)

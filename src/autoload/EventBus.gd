extends Node

#dialogue load and unload signal
signal dialogue_requested(data: Dictionary)
signal dialogue_finished()

#scene transition signal
signal background_change_requested(id: String) 

#signal for ui
signal player_advanced_dialogue
signal player_skipped_dialogue

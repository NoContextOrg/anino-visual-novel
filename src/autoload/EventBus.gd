extends Node

#dialogue load and unload signal
signal dialogue_requested(data: Dictionary)
signal dialogue_finished()

#scene transition signal
signal background_change_requested(id: String) 

#signal for ui
signal advance_requested
signal skip_convo_requested

# choice system
signal choices_requested(choices: Array)
signal choice_selected(index: int)

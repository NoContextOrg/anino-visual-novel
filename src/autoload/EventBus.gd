extends Node

#dialogue load and unload signal
signal dialogue_requested(data: Dictionary)
signal dialogue_finished()

#scene transition signal
signal background_change_requested(id: String)

func request_background_change(id: String) -> void:
	background_change_requested.emit(id)

#signal for ui
signal advance_requested
signal skip_convo_requested

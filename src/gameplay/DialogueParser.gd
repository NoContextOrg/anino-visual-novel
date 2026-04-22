extends Node

var dialogue_data = []
var current_index = 0

func load_dialogue(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open file")
		return
	
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	
	if typeof(json) != TYPE_ARRAY:
		push_error("Invalid JSON format")
		return
	
	dialogue_data = json
	current_index = 0

func get_next_line():
	if current_index >= dialogue_data.size():
		return null  # End of file
	
	var line = dialogue_data[current_index]
	current_index += 1
	
	return line

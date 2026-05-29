extends Node

var dialogue_data = []
var current_index = 0

var waiting_for_advance = false
@onready var event_bus = get_node_or_null("/root/EventBus")


func load_dialogue(path: String):
	print("LOADING DIALOGUE FROM:", path)
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


func start():
	current_index = 0
	process_next_line()


func process_next_line():
	# end of dialogue
	if current_index >= dialogue_data.size():
		print("DialogueParser: Dialogue finished, emitting dialogue_finished")
		if event_bus:
			event_bus.dialogue_finished.emit()
		return
	
	var line = dialogue_data[current_index]
	current_index += 1
	
	print("DialogueParser: Processing line ", current_index - 1, ": ", line)
	_handle_line(line)


func _handle_line(line):
	var text = line.get("text", "")

	# -----------------------
	# COMMAND SYSTEM [bg:]
	# -----------------------
	if text.begins_with("[") and text.ends_with("]"):
		var command = text.strip_edges()
		command = command.substr(1, command.length() - 2)

		var parts = command.split(":", true, 1)
		var key = parts[0].strip_edges()
		var value = parts[1].strip_edges() if parts.size() > 1 else ""

		match key:
			"bg":
				if event_bus:
					event_bus.background_change_requested.emit(value)

			"sfx":
				if event_bus:
					event_bus.play_sfx_requested.emit(value)

			"anim":
				var anim_parts = value.split(" ", true, 1)
				var action = anim_parts[0] if anim_parts.size() > 0 else ""
				var anim_name = anim_parts[1] if anim_parts.size() > 1 else ""
				if event_bus:
					event_bus.sprite_anim_requested.emit(action, anim_name)

			_:
				push_warning("Unknown command: " + key)

		process_next_line()
		return


	# -----------------------
	# NORMAL DIALOGUE + SFX
	# -----------------------
	print("DialogueParser: Emitting dialogue_requested with speaker: ", line.get("speaker", ""))
	if event_bus:
		event_bus.dialogue_requested.emit({
		"speaker": line.get("speaker", ""),
		"text": text,
		"expression": line.get("expression", "")
		})

	# ✔ play SFX if attached
	if line.has("sfx"):
		if event_bus:
			event_bus.play_sfx_requested.emit(line["sfx"])

	waiting_for_advance = true


func _ready():
	if event_bus == null:
		push_error("EventBus autoload not found at /root/EventBus.")
		return
	# UI signals
	event_bus.advance_requested.connect(_on_advance_requested)
	event_bus.skip_convo_requested.connect(_on_skip_requested)
	
	# choice signals
	event_bus.choice_selected.connect(_on_choice_selected)


func _on_advance_requested():
	if not waiting_for_advance:
		return
	
	waiting_for_advance = false
	process_next_line()


func _on_skip_requested():
	current_index = dialogue_data.size()
	waiting_for_advance = false
	if event_bus:
		event_bus.dialogue_finished.emit()
	
func _on_choice_selected(index):
	var line = dialogue_data[current_index - 1]
	var choices = line["choices"]
	
	if index < 0 or index >= choices.size():
		push_warning("Invalid choice index")
		return
	
	current_index = choices[index]["next"]
	waiting_for_advance = false
	process_next_line()

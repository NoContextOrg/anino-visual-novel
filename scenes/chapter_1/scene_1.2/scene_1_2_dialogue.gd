extends Control

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $Dialogue/DialogueLabel
@onready var name_label = $Name/NameLabel

var _active_tween: Tween

# JSON dialogue file to load at runtime
@export_file("*.json") var dialogue_path: String = "res://story/chapter_1/scene_1_2_dialogue.json"
@export var typewriter_duration: float = 2.5
var dialogue_queue: Array = []
var current_line_index: int = 0

func _ready():
	load_dialogue(dialogue_path)
	play_current_line()

func load_dialogue(path: String) -> void:
	if path.is_empty():
		push_warning("SampleDialogueBox: dialogue_path is empty.")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SampleDialogueBox: Failed to open dialogue file: %s" % path)
		return

	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	if typeof(json) != TYPE_ARRAY:
		push_error("SampleDialogueBox: Dialogue JSON must be an array.")
		return

	dialogue_queue = json
	current_line_index = 0

func play_current_line():
	if current_line_index < dialogue_queue.size():
		var current_dialogue = dialogue_queue[current_line_index]
		if typeof(current_dialogue) != TYPE_DICTIONARY:
			push_warning("SampleDialogueBox: Skipping invalid dialogue line.")
			current_line_index += 1
			play_current_line()
			return

		var text = current_dialogue.get("text", "")
		if text.begins_with("[") and text.ends_with("]"):
			current_line_index += 1
			play_current_line()
			return

		var speaker = current_dialogue.get("speaker", current_dialogue.get("name", ""))
		display_text(speaker, text)
	else:
		end_dialogue()

func display_text(char_name: String, text: String):
	name_label.text = char_name
	dialogue_label.text = text
	
	# Typewriter Effect
	dialogue_label.visible_ratio = 0.0
	
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
		
	_active_tween = create_tween()
	_active_tween.tween_property(dialogue_label, "visible_ratio", 1.0, typewriter_duration).set_trans(Tween.TRANS_LINEAR)

func end_dialogue():
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	current_line_index = dialogue_queue.size() #temporary function
	hide()

# Click-to-Advance or Space-to-Skip
func _input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		end_dialogue()
		return 
		
	if event.is_action_pressed("ui_advance"):
		if dialogue_label.visible_ratio < 1.0:
			if _active_tween and _active_tween.is_running():
				_active_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
			current_line_index += 1
			play_current_line() #Temporary call

extends Control

signal dialogue_finished

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $Dialogue/DialogueLabel
@onready var name_label = $Name/NameLabel

var _active_tween: Tween
var _dialogue_base_position := Vector2.ZERO
var _shake_rng := RandomNumberGenerator.new()
var _shake_active := false

@export var emphasis_shake_text: String = "YOU ARE NOW PART OF IT!"
@export var emphasis_shake_strength: float = 6.0
@export var emphasis_shake_duration: float = 0.4
@export var emphasis_shake_steps: int = 8

# JSON dialogue file to load at runtime
@export_file("*.json") var dialogue_path: String = "res://story/chapter_1/scene_1_2_dialogue.json"
@export var typewriter_duration: float = 2.5
var dialogue_queue: Array = []
var current_line_index: int = 0

func _ready():
	load_dialogue(dialogue_path)
	_dialogue_base_position = position
	_shake_rng.randomize()
	set_process(false)
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

	if _matches_emphasis_text(text):
		_play_emphasis_shake()
	else:
		_stop_emphasis_shake()

func _matches_emphasis_text(text: String) -> bool:
	return _normalize_emphasis_text(text) == _normalize_emphasis_text(emphasis_shake_text)

func _normalize_emphasis_text(value: String) -> String:
	var trimmed = value.strip_edges()
	while trimmed.length() > 0:
		var last = trimmed[trimmed.length() - 1]
		if last == "." or last == "!" or last == "?":
			trimmed = trimmed.substr(0, trimmed.length() - 1)
		else:
			break
	return trimmed.to_upper()

func _play_emphasis_shake() -> void:
	if emphasis_shake_strength <= 0.0 or emphasis_shake_duration <= 0.0:
		return

	_dialogue_base_position = position
	_shake_active = true
	set_process(true)

func _stop_emphasis_shake() -> void:
	_shake_active = false
	position = _dialogue_base_position
	set_process(false)

func _process(delta: float) -> void:
	if not _shake_active:
		position = _dialogue_base_position
		set_process(false)
		return

	var strength = emphasis_shake_strength
	var offset = Vector2(
		_shake_rng.randf_range(-strength, strength),
		_shake_rng.randf_range(-strength, strength)
	)
	position = _dialogue_base_position + offset

func end_dialogue():
	if _active_tween and _active_tween.is_running():
		_active_tween.kill()
	current_line_index = dialogue_queue.size() #temporary function
	set_process_input(false)
	hide()
	dialogue_finished.emit()

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

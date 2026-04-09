extends Control

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $Dialogue/DialogueLabel
@onready var name_label = $Name/NameLabel

var _active_tween: Tween

# Test data only, temporary parser
var dialogue_queue = [
	{"name": "Kian", "text": "Hello, testing line, lorem ipsum bro"},
	{"name": "Carl E", "text": "try the left click to advance the typewriting effect"},
	{"name": "Carl B", "text": "wowww, try space to finish all the convo"},
	{"name": "Ezekiel", "text": "testing line for your space"},
	{"name": "Jhered", "text": "last testing line for your space"}
]
var current_line_index = 0

func _ready():
	play_current_line()

func play_current_line():
	if current_line_index < dialogue_queue.size():
		var current_dialogue = dialogue_queue[current_line_index]
		display_text(current_dialogue["name"], current_dialogue["text"])
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
	_active_tween.tween_property(dialogue_label, "visible_ratio", 1.0, 1.0).set_trans(Tween.TRANS_LINEAR)

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

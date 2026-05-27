extends Control

# Custom Signals
signal advance_requested
signal skip_convo_requested

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $DialogueLabel
@onready var name_label = $NameLabel

var _active_tween: Tween

func _ready():
	# Hide the box when the scene first loads
	hide()
	
	# 1. Listen for the EventBus to give us text, and send it straight to your display_text function
	EventBus.dialogue_requested.connect(display_text)
	
	# 2. When the player clicks to advance, tell your global Parser to give us the next line!
	# (Assuming your DialogueParser.gd has a function to advance the line, like advance_dialogue)
func display_text(char_name: String, text: String):
	show()
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
	hide()

# Click-to-Advance or Space-to-Skip
func _input(event):
	EventBus.advance_requested.emit()
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		end_dialogue()
		skip_convo_requested.emit()
		return 
		
	if event.is_action_pressed("ui_advance"):
		if dialogue_label.visible_ratio < 1.0:
			if _active_tween and _active_tween.is_running():
				_active_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
			advance_requested.emit()

extends Control

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $Dialogue/DialogueLabel
@onready var name_label = $Name/NameLabel

var _active_tween: Tween

var current_line_index = 0

func _ready():
	hide()
	EventBus.dialogue_requested.connect(display_text)
	EventBus.dialogue_finished.connect(end_dialogue)

func display_text(data: Dictionary):
	show()
	name_label.text = data.get("speaker", "")
	dialogue_label.text = data.get("text", "")
	
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
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		end_dialogue()
		EventBus.skip_convo_requested.emit()
		return

	if event.is_action_pressed("ui_advance"):
		if dialogue_label.visible_ratio < 1.0:
			if _active_tween and _active_tween.is_running():
				_active_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
			EventBus.advance_requested.emit()
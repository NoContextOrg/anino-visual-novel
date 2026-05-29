extends Control

# RichTextLabel for dialogue, Label for name
@onready var dialogue_label = $Dialogue/DialogueLabel
@onready var name_label = $Name/NameLabel
@onready var event_bus = get_node_or_null("/root/EventBus")

var _active_tween: Tween

# Test data only, temporary parser

var current_line_index = 0

func _ready():
	hide()
	if event_bus == null:
		push_error("EventBus autoload not found at /root/EventBus.")
		return
	event_bus.dialogue_requested.connect(display_text)
	event_bus.dialogue_finished.connect(end_dialogue)


func display_text(data: Dictionary):
	show()
	name_label.text = data.get("speaker", "")
	dialogue_label.text = data.get("text", "")
	# keep the rest as-is
	
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
		if event_bus:
			event_bus.skip_convo_requested.emit()
		return

	if event.is_action_pressed("ui_advance"):
		if dialogue_label.visible_ratio < 1.0:
			if _active_tween and _active_tween.is_running():
				_active_tween.kill()
			dialogue_label.visible_ratio = 1.0
		else:
			if event_bus:
				event_bus.advance_requested.emit()

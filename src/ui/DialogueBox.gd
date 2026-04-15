extends PanelContainer
## Displays dialogue text with a typewriter effect and a speaker name label.
##
## Listens to [signal EventBus.dialogue_started] to receive new lines, plays
## the text out character-by-character, and lets the player click or press
## a key to either skip the animation or advance to the next line.

## Emitted after the full line is visible and the player presses advance.
signal advance_requested

## Characters revealed per second during the typewriter effect.
@export var characters_per_second: float = 30.0

@onready var _name_label: Label = %NameLabel
@onready var _dialogue_text: RichTextLabel = %DialogueText

var _tween: Tween
var _is_typing: bool = false


func _ready() -> void:
	EventBus.dialogue_started.connect(_on_dialogue_started)
	# Start hidden until the first dialogue line arrives.
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	var pressed := false
	if event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventKey:
		pressed = event.pressed and not event.echo and (
			event.keycode == KEY_SPACE or event.keycode == KEY_ENTER
		)

	if pressed:
		if _is_typing:
			_skip_typewriter()
		else:
			advance_requested.emit()
		get_viewport().set_input_as_handled()


## Display a new dialogue line with the typewriter effect.
func display_line(speaker: String, text: String) -> void:
	_name_label.text = speaker
	_name_label.visible = speaker != ""
	_dialogue_text.text = text
	show()
	_start_typewriter()


## Instantly reveal the remaining text.
func _skip_typewriter() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_dialogue_text.visible_ratio = 1.0
	_is_typing = false


func _start_typewriter() -> void:
	_skip_typewriter()  # Kill any previous tween
	_dialogue_text.visible_ratio = 0.0

	var char_count := _dialogue_text.get_total_character_count()
	if char_count == 0:
		_is_typing = false
		return

	var duration := char_count / characters_per_second
	_is_typing = true
	_tween = create_tween()
	_tween.tween_property(_dialogue_text, "visible_ratio", 1.0, duration)
	_tween.finished.connect(_on_typewriter_finished)


func _on_typewriter_finished() -> void:
	_is_typing = false


func _on_dialogue_started(data: Dictionary) -> void:
	var speaker: String = data.get("name", "")
	var text: String = data.get("text", "")
	display_line(speaker, text)

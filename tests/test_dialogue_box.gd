extends GutTest
## Unit tests for the DialogueBox UI component.


const DialogueBoxScene = preload("res://scenes/ui/DialogueBox.tscn")


var _box: PanelContainer


func before_each() -> void:
	_box = DialogueBoxScene.instantiate()
	add_child_autofree(_box)
	# The box starts hidden.
	await get_tree().process_frame


func test_starts_hidden() -> void:
	assert_false(_box.visible, "DialogueBox should start hidden")


func test_display_line_shows_box() -> void:
	_box.display_line("Alice", "Hello world!")
	assert_true(_box.visible, "display_line should make the box visible")


func test_display_line_sets_speaker_name() -> void:
	_box.display_line("Bob", "Some text")
	var name_label: Label = _box.find_child("NameLabel")
	assert_eq(name_label.text, "Bob")


func test_display_line_sets_dialogue_text() -> void:
	_box.display_line("Bob", "Some text")
	var dialogue: RichTextLabel = _box.find_child("DialogueText")
	assert_eq(dialogue.text, "Some text")


func test_empty_speaker_hides_name_label() -> void:
	_box.display_line("", "Narration line")
	var name_label: Label = _box.find_child("NameLabel")
	assert_false(name_label.visible, "NameLabel should be hidden for empty speaker")


func test_typewriter_starts_at_zero_ratio() -> void:
	_box.display_line("Alice", "Hello!")
	var dialogue: RichTextLabel = _box.find_child("DialogueText")
	assert_eq(dialogue.visible_ratio, 0.0,
		"visible_ratio should start at 0 during typewriter")


func test_skip_typewriter_reveals_all_text() -> void:
	_box.display_line("Alice", "Hello!")
	_box._skip_typewriter()
	var dialogue: RichTextLabel = _box.find_child("DialogueText")
	assert_eq(dialogue.visible_ratio, 1.0,
		"visible_ratio should be 1 after skipping")


func test_on_dialogue_started_via_eventbus() -> void:
	EventBus.dialogue_started.emit({"name": "Eve", "text": "Bus test"})
	await get_tree().process_frame
	assert_true(_box.visible, "Box should appear when EventBus signal fires")
	var name_label: Label = _box.find_child("NameLabel")
	assert_eq(name_label.text, "Eve")


func test_characters_per_second_export_default() -> void:
	assert_gt(_box.characters_per_second, 0.0,
		"characters_per_second should have a positive default")

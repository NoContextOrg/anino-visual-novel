extends Node

@export var chapters: Dictionary = {}
@export var background_first := true
@export var sequence: Array[String] = []
@export var advance_on_dialogue_finished := false
@export var debug_input_enabled := false
@export var debug_next_action: StringName = &"ui_focus_next"

var _current_index := -1

func _ready() -> void:
	if advance_on_dialogue_finished:
		EventBus.dialogue_finished.connect(_on_chapter_finished)

func _exit_tree() -> void:
	if EventBus.dialogue_finished.is_connected(_on_chapter_finished):
		EventBus.dialogue_finished.disconnect(_on_chapter_finished)

func _unhandled_input(event: InputEvent) -> void:
	if not debug_input_enabled:
		return
	if event.is_action_pressed(debug_next_action):
		next_chapter()

func request_scene_change(target_path: String, background_id: String = "") -> void:
	if target_path.is_empty():
		push_warning("SceneManager received an empty target path.")
		return

	if background_first and not background_id.is_empty():
		EventBus.background_change_requested.emit(background_id)

	EventBus.scene_change_requested.emit(target_path)

	if not background_first and not background_id.is_empty():
		EventBus.background_change_requested.emit(background_id)

func go_to_chapter(chapter_id: String) -> void:
	if not chapters.has(chapter_id):
		push_warning("Unknown chapter id: %s" % chapter_id)
		return

	var chapter = chapters.get(chapter_id, {})
	var target_path := ""
	var background_id := ""

	if typeof(chapter) == TYPE_DICTIONARY:
		target_path = chapter.get("scene", "")
		background_id = chapter.get("background", "")

	request_scene_change(target_path, background_id)

func start_sequence() -> void:
	_current_index = -1
	next_chapter()

func next_chapter() -> void:
	if sequence.is_empty():
		push_warning("SceneManager sequence is empty.")
		return

	_current_index += 1
	if _current_index >= sequence.size():
		push_warning("SceneManager reached the end of the sequence.")
		return

	_run_sequence_entry(sequence[_current_index])

func _run_sequence_entry(entry: String) -> void:
	if chapters.has(entry):
		var chapter = chapters.get(entry, {})
		var target_path := ""
		var background_id := ""

		if typeof(chapter) == TYPE_DICTIONARY:
			target_path = chapter.get("scene", "")
			background_id = chapter.get("background", "")

		request_scene_change(target_path, background_id)
		return

	request_scene_change(entry)

func _on_chapter_finished() -> void:
	next_chapter()

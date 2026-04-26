extends Control

# Signal Architecture 
signal chapter_selected(index: int)
enum ChapterState { LOCKED, UNLOCKED, COMPLETED }

@onready var grid_container: GridContainer = _resolve_grid_container()

func _ready() -> void:
	if not grid_container:
		push_error("MapSelection setup error: GridContainer not found")
		return

	_connect_buttons()
	
	# testing visual states, remove this if the script 
	# will be connected na on the EventBus
	set_chapter_state(1, ChapterState.COMPLETED)
	set_chapter_state(2, ChapterState.UNLOCKED)
	set_chapter_state(3, ChapterState.LOCKED)
	set_chapter_state(4, ChapterState.LOCKED)
	set_chapter_state(5, ChapterState.LOCKED)
	# Delete until here

func _resolve_grid_container() -> GridContainer:
	var candidate_paths: Array[NodePath] = [
		NodePath("GridContainer"),
		NodePath("MapSelection/GridContainer"),
		NodePath("UI_Anchor/MapSelection/GridContainer")
	]

	for candidate_path in candidate_paths:
		var container := get_node_or_null(candidate_path) as GridContainer
		if container:
			return container

	return null

func _connect_buttons() -> void:
	for i in range(grid_container.get_child_count()):
		var button = grid_container.get_child(i) as Button
		if button:
			var chapter_index = i + 1
			var callback := _on_chapter_button_pressed.bind(chapter_index)
			if not button.pressed.is_connected(callback):
				button.pressed.connect(callback)

func _on_chapter_button_pressed(index: int) -> void:
	chapter_selected.emit(index)
	print("Signal Emitted: Chapter ", index,) 
	
# Visual States 
func set_chapter_state(chapter_index: int, state: ChapterState) -> void:
	if not grid_container:
		return

	var button_index := chapter_index - 1
	if button_index < 0 or button_index >= grid_container.get_child_count():
		push_warning("MapSelection: Invalid chapter index %d" % chapter_index)
		return

	var button = grid_container.get_child(button_index) as Button
	if not button:
		return
		
	match state:
		ChapterState.LOCKED:
			button.disabled = true
			button.theme_type_variation = &"LockedChapterButton" 
			
		ChapterState.UNLOCKED:
			button.disabled = false
			button.theme_type_variation = &"UnlockedChapterButton" 
			
		ChapterState.COMPLETED:
			button.disabled = false
			button.theme_type_variation = &"CompletedChapterButton"



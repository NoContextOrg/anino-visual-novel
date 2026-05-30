extends Control

signal chapter_selected(index: int)
enum ChapterState { LOCKED, UNLOCKED, COMPLETED }

@onready var grid_container: Control = $Container
@onready var animation_player: AnimationPlayer = $AnimationPlayer 

func _ready() -> void:
	_connect_buttons()
	
	grid_container.hide() 
	animation_player.play("level_map") 
	await animation_player.animation_finished 
	grid_container.show() 

	set_chapter_state(1, ChapterState.UNLOCKED)
	set_chapter_state(2, ChapterState.LOCKED)
	set_chapter_state(3, ChapterState.LOCKED)
	set_chapter_state(4, ChapterState.LOCKED)
	set_chapter_state(5, ChapterState.LOCKED)

func _connect_buttons() -> void:
	for i in range(grid_container.get_child_count()):
		var button = grid_container.get_child(i) as Button
		if button:
			var chapter_index = i + 1
			button.pressed.connect(_on_chapter_button_pressed.bind(chapter_index))

func _on_chapter_button_pressed(index: int) -> void:
	chapter_selected.emit(index)
	print("Signal Emitted: Chapter ", index)
	if index == 1:
		SceneManager.request_scene_change("res://scenes/chapter_1/scene_1/scene_1.tscn")

# Visual States
func set_chapter_state(chapter_index: int, state: ChapterState) -> void:
	var button = grid_container.get_child(chapter_index - 1) as Button
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

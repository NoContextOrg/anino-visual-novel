extends Control

const FIRST_CHAPTER_PATH := "res://scenes/templates/MasterChapter.tscn"
const OPTIONS_MENU_PATH := "res://scenes/ui/OptionsMenu.tscn"

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(FIRST_CHAPTER_PATH)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(OPTIONS_MENU_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control

@onready var play_button = $MarginContainer/VBoxContainer/PlayButton
@onready var settings_button = $MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton
@onready var load_button = $MarginContainer/VBoxContainer/LoadButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	load_button.pressed.connect(_on_load_pressed)

func _on_play_pressed():
	# Make sure this file name is exactly correct!
	get_tree().change_scene_to_file("res://scenes/templates/chapter_1.tscn")
	
func _on_load_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/load_game_menu.tscn")


func _on_settings_pressed():
	# Points to the new scene we made in Step 4
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

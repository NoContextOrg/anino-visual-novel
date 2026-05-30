extends Control

@onready var play_button = $ButtonContainer/VBoxContainer/PlayButton
@onready var load_button = $ButtonContainer/VBoxContainer/Load
@onready var settings_button = $ButtonContainer/VBoxContainer/SettingsButton
@onready var quit_button = $ButtonContainer/VBoxContainer/QuitButton
@onready var animation_player = $AnimationPlayer

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	load_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	animation_player.play("burn")

func _on_play_pressed():
	SceneManager.request_scene_change("res://scenes/ui/map_selection.tscn")

func _on_load_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/load_game.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

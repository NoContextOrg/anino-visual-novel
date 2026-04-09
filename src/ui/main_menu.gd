extends Control

# This connects the buttons in the editor to the code
@onready var play_button = $MarginContainer/VBoxContainer/PlayButton
@onready var settings_button = $MarginContainer/VBoxContainer/SettingsButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton

func _ready():
	# Connect the buttons to the functions below
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	# Switches to the chapter template
	get_tree().change_scene_to_file("res://scenes/templates/chapter_1.tscn")

func _on_settings_pressed():
	# Switches to the options screen
	get_tree().change_scene_to_file("res://scenes/ui/Options.tscn")

func _on_quit_pressed():
	get_tree().quit()
	
func _process(delta):
	# This makes the title "float" up and down slightly like it's breathing
	$MarginContainer/VBoxContainer/Title.position.y += sin(Time.get_ticks_msec() * 0.002) * 0.1
	$MarginContainer/VBoxContainer/Subtitle.position.y += sin(Time.get_ticks_msec() * 0.002) * 0.1

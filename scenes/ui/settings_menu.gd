extends Control

# Reference the back button
@onready var back_button = $MarginContainer/VBoxContainer/back_button

func _ready():
	# Connect the button click to the function below
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	# Go back to the Main Menu scene
	# Verify this path matches your renamed file!
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

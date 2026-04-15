extends Control

const MAIN_MENU_PATH := "res://scenes/ui/MainMenu.tscn"

@onready var back_button: Button = %BackButton
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var volume_value_label: Label = %VolumeValueLabel


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	_update_volume_label(master_volume_slider.value)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _on_master_volume_changed(value: float) -> void:
	_update_volume_label(value)


func _update_volume_label(value: float) -> void:
	volume_value_label.text = str(int(value)) + "%"

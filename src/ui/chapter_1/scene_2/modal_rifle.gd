extends CanvasLayer

@onready var close_button = $Control/Button

func _ready() -> void:
	hide()
	close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed() -> void:
	hide()

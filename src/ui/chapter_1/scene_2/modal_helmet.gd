extends CanvasLayer

@onready var close_button = $Control/Button

func _ready() -> void:
	print("[DEBUG] Rifle modal loaded")
	hide()
	close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed() -> void:
	print("[DEBUG] Close button clicked")
	hide()

extends TextureButton

@export var closeup_image_path: String

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if closeup_image_path.is_empty():
		return
	EventBus.show_image_modal_requested.emit(closeup_image_path)

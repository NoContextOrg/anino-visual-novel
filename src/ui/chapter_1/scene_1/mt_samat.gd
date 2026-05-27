extends CanvasLayer
class_name ModalMtSamat

@onready var texture_rect = $Control/TextureRect
@onready var close_button = $Control/Button
@onready var rich_text_label = $RichTextLabel

const EXPECTED_IMAGE := "res://assets/hotspots/chapter_1/scene_1/mt_samat.png"

func _ready() -> void:
	hide()
	EventBus.show_image_modal_requested.connect(_on_show_modal_requested)
	close_button.pressed.connect(_on_close_button_pressed)

func _on_show_modal_requested(image_path: String) -> void:
	if image_path != EXPECTED_IMAGE:
		return
	var new_image = load(image_path)
	if new_image:
		texture_rect.texture = new_image
		rich_text_label.text = "Mount Samat stands as a silent witness to the fierce battles fought on the Bataan Peninsula during World War II."
		show()
	else:
		push_error("Modal couldn't find image: " + image_path)

func _on_close_button_pressed() -> void:
	hide()

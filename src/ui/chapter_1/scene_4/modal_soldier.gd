extends CanvasLayer

@onready var texture_rect = $Control/TextureRect
@onready var close_button = $Control/CloseButton
@onready var rich_text_label = $Control/RichTextLabel

const EXPECTED_IMAGE := "res://assets/chapter_1/scene_4/man/thirsty_soldier_single_whitebg_2.png"

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
		rich_text_label.text = "Rations in Bataan had fallen to less than 1,000 calories a day.\n\nFood supplies, originally planned for a much shorter campaign, were quickly depleted after the retreat into the peninsula.\n\nWhat remained was stretched as long as possible\u2014but it was never enough."
		show()
	else:
		push_error("Modal couldn't find image: " + image_path)

func _on_close_button_pressed() -> void:
	hide()

extends CanvasLayer

@onready var texture_rect = $Control/TextureRect
@onready var close_button = $Control/Button
const EXPECTED_IMAGE := "res://assets/hotspots/chapter_1/scene_2/rifle.png"
func _ready() -> void:
	# 1. Hide the modal by default when the game starts
	hide()
	
	# 2. Listen to the EventBus
	EventBus.show_image_modal_requested.connect(_on_show_modal_requested)
	
	# 3. Connect the close button
	close_button.pressed.connect(_on_close_button_pressed)

func _on_show_modal_requested(image_path: String) -> void:
	if image_path != EXPECTED_IMAGE:
		return
	# Load the requested image from the file path
	var new_image = load(image_path)
	if new_image:
		texture_rect.texture = new_image
		texture_rect.custom_minimum_size = new_image.get_size()
		texture_rect.size = new_image.get_size()
		texture_rect.position = (get_viewport().get_visible_rect().size - texture_rect.size) * 0.5
		show() # Make the modal visible!
	else:
		push_error("Modal couldn't find the image at: " + image_path)

func _on_close_button_pressed() -> void:
	hide() # Hide the modal when the player clicks "Close"

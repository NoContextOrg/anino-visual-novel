extends TextureRect

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		EventBus.show_image_modal_requested.emit("res://assets/hotspots/chapter_1/scene_2/rifle.png")

extends TextureRect

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var tex := texture
		var path := ""
		if tex and tex.resource_path != "":
			path = tex.resource_path
		if path == "":
			# fallback to known path if texture not set
			path = "res://assets/hotspots/chapter_1/scene_2/rifle.png"
		EventBus.show_image_modal_requested.emit(path)

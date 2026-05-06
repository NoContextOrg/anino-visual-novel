extends TextureButton

@onready var helmet_modal: CanvasLayer = get_node_or_null("../ModalHelmet")

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_pressed() -> void:
	# Reset the cursor
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if helmet_modal:
		EventBus.play_sfx_requested.emit("res://assets/chapter_1/scene_2/distant_explosion.mp3", -15.0)
		helmet_modal.show()
	else:
		push_error("Rifle modal node not found.")

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

extends TextureButton

@onready var rifle_modal: CanvasLayer = get_node_or_null("../ModalRifle")

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Set pivot to center so scaling doesn't move the button
	pivot_offset = size / 2

func _on_pressed() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


	print("[DEBUG] Rifle modal found, showing...")
	EventBus.play_sfx_requested.emit("res://assets/chapter_1/scene_2/metal_sound.mp3", -10.0)
	rifle_modal.show()


func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.15)
	tween.parallel().tween_property(self, "modulate", Color.WHITE.lightened(0.3), 0.15)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.15)

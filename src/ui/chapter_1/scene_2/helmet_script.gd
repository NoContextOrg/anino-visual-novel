extends TextureButton

# Drag and drop your close-up image from the FileSystem into this variable in the Inspector!
@export var closeup_image_path: String = "res://assets/ui/map_closeup.png"

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_pressed() -> void:
	# Reset the cursor
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	# Tell the EventBus to open the modal with THIS specific image!
	EventBus.show_image_modal_requested.emit(closeup_image_path)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

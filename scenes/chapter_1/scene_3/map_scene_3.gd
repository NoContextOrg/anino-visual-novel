class_name TableMapScene
extends Control

@onready var scroll_panel: ScrollPopupPanel = $scroll_panel
@onready var interactables: Control = $background/interactables
@onready var dark_overlay: ColorRect = $background/dark_overlay
@onready var bg_anim: AnimationPlayer = $background/bg_animation
@onready var next_button: TextureButton = $UI_Anchor/NextButton


func _ready() -> void:
	scroll_panel.hide()
	_setup_next_button()


	if dark_overlay:
		dark_overlay.hide()
		dark_overlay.gui_input.connect(_on_dark_overlay_clicked)

	bg_anim.play("table_moving")

	scroll_panel.closed.connect(_on_popup_closed)

	for button in interactables.get_children():
		if button is TextureButton:
			if button.texture_normal == null:
				continue
			var mask = BitMap.new()
			mask.create_from_image_alpha(button.texture_normal.get_image())
			button.texture_click_mask = mask

			button.pressed.connect(_on_item_pressed.bind(button.name))
			button.mouse_entered.connect(_on_hover.bind(button, true))
			button.mouse_exited.connect(_on_hover.bind(button, false))



func _on_item_pressed(button_name: String) -> void:
	if ItemDatabase.INFO.has(button_name):
		scroll_panel.display_info(ItemDatabase.INFO[button_name])
		if dark_overlay:
			dark_overlay.show()

func _on_popup_closed() -> void:
	if dark_overlay:
		dark_overlay.hide()

func _on_dark_overlay_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		scroll_panel.hide()
		_on_popup_closed()

func _on_hover(button: TextureButton, is_hovered: bool) -> void:

	if is_hovered:
		var theme_glow = button.get_theme_color("icon_hover_color", "TableItemButton")
		button.self_modulate = theme_glow

	else:
		button.self_modulate = Color.WHITE

func _setup_next_button() -> void:
	if next_button == null:
		return

	next_button.texture_normal = load("res://assets/ui/hud_interfaces/next.png")

	if not next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.connect(_on_next_pressed)
	if not next_button.mouse_entered.is_connected(_on_next_hovered):
		next_button.mouse_entered.connect(_on_next_hovered)
	if not next_button.mouse_exited.is_connected(_on_next_unhovered):
		next_button.mouse_exited.connect(_on_next_unhovered)

	_position_next_button()

func _position_next_button() -> void:
	var texture: Texture2D = next_button.texture_normal
	if texture == null:
		return
	var tex_size := texture.get_size()
	next_button.custom_minimum_size = tex_size
	next_button.size = tex_size
	next_button.pivot_offset = tex_size * 0.5
	next_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	var margin := Vector2(32, 32)
	next_button.offset_right = -margin.x
	next_button.offset_bottom = -margin.y
	next_button.offset_left = -margin.x - tex_size.x
	next_button.offset_top = -margin.y - tex_size.y

func _on_next_hovered() -> void:
	next_button.scale = Vector2(1.05, 1.05)

func _on_next_unhovered() -> void:
	next_button.scale = Vector2.ONE

func _on_next_pressed() -> void:
	SceneManager.request_scene_change("res://scenes/chapter_1/scene_4/scene_4.tscn")

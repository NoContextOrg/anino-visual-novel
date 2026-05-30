class_name TableMapScene
extends Control

@onready var scroll_panel: ScrollPopupPanel = $scroll_panel
@onready var interactables: Control = $background/interactables
@onready var dark_overlay: ColorRect = $background/dark_overlay
@onready var bg_anim: AnimationPlayer = $background/bg_animation


func _ready() -> void:
	scroll_panel.hide()


	if dark_overlay:
		dark_overlay.hide()
		dark_overlay.gui_input.connect(_on_dark_overlay_clicked)

	bg_anim.play("table_moving")

	scroll_panel.closed.connect(_on_popup_closed)

	for button in interactables.get_children():
		if button is TextureButton:
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

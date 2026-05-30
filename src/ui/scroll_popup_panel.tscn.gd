class_name ScrollPopupPanel
extends Control

@onready var info_label: Label = $scroll_popup_panel/margin_container/label
@onready var close_btn: TextureButton = $close_btn 

signal closed 

func _ready() -> void:
	close_btn.mouse_entered.connect(_on_hover.bind(true))
	close_btn.mouse_exited.connect(_on_hover.bind(false))

func display_info(text_content: String) -> void:
	info_label.text = text_content
	show() 

func _on_close_btn_pressed() -> void:
	hide()
	closed.emit()

func _on_hover(is_hovered: bool) -> void:
	if is_hovered:
		var theme_glow = close_btn.get_theme_color("icon_hover_color", "TableItemButton")
		close_btn.self_modulate = theme_glow
	else:
		close_btn.self_modulate = Color.WHITE

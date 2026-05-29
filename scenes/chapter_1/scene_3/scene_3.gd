class_name TableMapScene
extends Control

# I put "$background/" back in front of these paths where they belong!
@onready var scroll_panel: PopupPanel = $background/scroll_panel
@onready var info_label: Label = $background/scroll_panel/scroll_popup_panel/margin_container/label
@onready var interactables: Control = $background/interactables
@onready var dark_overlay: ColorRect = $background/dark_overlay 
@onready var bg_anim: AnimationPlayer = $background/bg_animation 
@onready var next_button: TextureButton = $UI_Anchor/NextButton

var item_info: Dictionary = {
	"canteen_btn": "The M1910 canteen was a standard-issue water container designed for durability and field use, often paired with a metal cup for boiling water. In Bataan, where dehydration was constant, it became a lifeline—though for many, it was never enough.",
	"hospital_report_btn": "The reports detail rising cases of malaria, dysentery, and malnutrition among the troops in Bataan. More soldiers were falling to disease and starvation than to enemy fire, overwhelming already strained medical units.",
	"war_map_btn": "info here",
	"journal_btn": "info here",
	"compass_btn": "The M1938 lensatic compass was used by soldiers for navigation and artillery coordination in difficult terrain. In the dense jungles of Bataan, it was essential for maintaining direction—especially as units became disoriented under pressure.",
	"pencil_btn": "info here",
	"medkit_btn": "info here"
}

func _ready() -> void:
	scroll_panel.hide()
	_setup_next_button()
	
	if dark_overlay:
		dark_overlay.hide() 
		dark_overlay.gui_input.connect(_on_dark_overlay_clicked) 
	
	bg_anim.play("table_moving")
	
	scroll_panel.popup_hide.connect(_on_popup_closed) 
	
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
	if item_info.has(button_name):
		info_label.text = item_info[button_name]
		if dark_overlay:
			dark_overlay.show()
		scroll_panel.popup_centered()

func _on_popup_closed() -> void:
	if dark_overlay:
		dark_overlay.hide()

func _on_dark_overlay_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		scroll_panel.hide() 

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

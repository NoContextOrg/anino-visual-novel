extends Control

# I put "$background/" back in front of these paths where they belong!
@onready var scroll_panel: PopupPanel = $background/scroll_panel
@onready var info_label: Label = $background/scroll_panel/scroll_popup_panel/margin_container/label
@onready var interactables: Control = $background/interactables
@onready var dark_overlay: ColorRect = $background/dark_overlay 
@onready var bg_anim: AnimationPlayer = $background/bg_animation 

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
	
	if dark_overlay:
		dark_overlay.hide() 
		dark_overlay.gui_input.connect(_on_dark_overlay_clicked) 
	
	bg_anim.play("table_moving")
	
	scroll_panel.popup_hide.connect(_on_popup_closed) 
	
	for button in interactables.get_children():
		if button is TextureButton:
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

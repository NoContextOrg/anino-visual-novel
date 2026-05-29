extends Node2D
class_name Scene1

var parser: Node

@onready var next_button: TextureButton = $UI_Anchor/NextButton

func _ready() -> void:
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	parser.load_dialogue("res://story/chapter_1/scene_1/scene_1_dialogue.json")
	parser.start()
	EventBus.dialogue_finished.connect(_on_dialogue_finished)
	_setup_next_button()
	# Disable hotspots until dialogue is done
	$ControlLayer/CrowButton.disabled = true
	$ControlLayer/MtSamatButton.disabled = true

func _on_dialogue_finished() -> void:
	# Enable hotspots after dialogue finishes
	$ControlLayer/CrowButton.disabled = false
	$ControlLayer/MtSamatButton.disabled = false
	# Connect button presses
	$ControlLayer/CrowButton.pressed.connect(_on_crow_clicked)
	$ControlLayer/MtSamatButton.pressed.connect(_on_mt_samat_clicked)
	# Show the next button after dialogue is done
	next_button.visible = true
	next_button.disabled = false

func _on_crow_clicked() -> void:
	EventBus.show_image_modal_requested.emit("res://assets/hotspots/chapter_1/scene_1/crow_closeup.png")

func _on_mt_samat_clicked() -> void:
	EventBus.show_image_modal_requested.emit("res://assets/hotspots/chapter_1/scene_1/mt_samat.png")

func _setup_next_button() -> void:
	if next_button == null:
		return
	next_button.texture_normal = load("res://assets/ui/hud_interfaces/next.png")
	next_button.visible = false
	next_button.disabled = true
	if not next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.connect(_on_next_pressed)
	if not next_button.mouse_entered.is_connected(_on_next_hovered):
		next_button.mouse_entered.connect(_on_next_hovered)
	if not next_button.mouse_exited.is_connected(_on_next_unhovered):
		next_button.mouse_exited.connect(_on_next_unhovered)
	_position_next_button()

func _position_next_button() -> void:
	if next_button.texture_normal == null:
		return
	var tex_size := next_button.texture_normal.get_size()
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
	SceneManager.request_scene_change("res://scenes/chapter_1/scene_1.2/scene_1.2.tscn")

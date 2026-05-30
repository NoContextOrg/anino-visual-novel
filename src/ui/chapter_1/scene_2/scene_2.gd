extends Node2D

@onready var background = $Background
@onready var animation_player = $AnimationPlayer
@onready var rifle_button = $RifleButton
@onready var helmet_button = $HelmetButton
@onready var sfx_player = $SFXPlayer
@onready var king = $dialogue_layer/king
@onready var next_button: TextureButton = $dialogue_layer/NextButton

@export_range(0.1, 90.0, 0.1) var fade_duration: float = 2.0
var current_bg: Texture2D = null

const DIMMED := Color(0.4, 0.4, 0.4, 1)
const BRIGHT := Color.WHITE

@onready var dimmable_nodes: Array[CanvasItem] = [
	$Background,
	$RifleButton,
	$HelmetButton,
	$Lamp,
]
var bg_busy := false
var _current_speaker := ""
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var fade_tween: Tween


func _ready():
	current_bg = load("res://assets/chapter_1/scene_2/background/inside_tent_bg_1.jpg")
	background.texture = current_bg
	animation_player.play("inside_tent")

	print("[DEBUG] RifleButton found: ", rifle_button)
	print("[DEBUG] HelmetButton found: ", helmet_button)
	print("[DEBUG] RifleButton script: ", rifle_button.get_script())
	print("[DEBUG] HelmetButton script: ", helmet_button.get_script())
	
	_create_fade_in_overlay()
	_setup_focus_system()
	_setup_next_button()

	EventBus.background_change_requested.connect(_on_bg_change)
	EventBus.play_sfx_requested.connect(_on_sfx)

	Parser.load_dialogue("res://story/chapter_1/scene_2/scene_2_dialogue.json")
	Parser.start()


func _create_fade_in_overlay():
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	if fade_layer and is_instance_valid(fade_layer):
		fade_layer.queue_free()

	fade_layer = CanvasLayer.new()
	fade_layer.name = "FadeLayer"
	fade_layer.layer = 10
	add_child(fade_layer)

	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_layer.add_child(fade_rect)

	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), fade_duration)
	fade_tween.finished.connect(_on_fade_in_finished)


func _on_fade_in_finished() -> void:
	if fade_layer and is_instance_valid(fade_layer):
		fade_layer.queue_free()

	fade_layer = null
	fade_rect = null
	fade_tween = null

func _setup_focus_system():
	king.visible = false
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.dialogue_finished.connect(_on_dialogue_finished)


func _on_dialogue_requested(data: Dictionary):
	var speaker = data.get("speaker", "")
	if speaker == _current_speaker:
		return
	_current_speaker = speaker
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	if speaker == "General King":
		king.modulate = Color(1, 1, 1, 0)
		king.visible = true
		tween.parallel().tween_property(king, "modulate", Color.WHITE, 0.25)
		for node in dimmable_nodes:
			tween.parallel().tween_property(node, "modulate", DIMMED, 0.25)
	else:
		tween.parallel().tween_property(king, "modulate:a", 0.0, 0.15)
		tween.tween_callback(func(): king.visible = false)
		for node in dimmable_nodes:
			tween.parallel().tween_property(node, "modulate", BRIGHT, 0.25)


func _on_dialogue_finished():
	_current_speaker = ""
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(king, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): king.visible = false)
	for node in dimmable_nodes:
		tween.parallel().tween_property(node, "modulate", BRIGHT, 0.25)

	next_button.visible = true
	next_button.disabled = false


func _on_bg_change(path: String):
	# rifle_button.visible = false
	# helmet_button.visible = false


	print("BG CHANGE CALLED:", path)
	animation_player.stop()

	if bg_busy:
		return

	bg_busy = true

	var new_bg = load(path)

	if new_bg == null:
		push_error("Failed to load: " + path)
		bg_busy = false
		return
	
	
	background.texture = new_bg
	current_bg = new_bg
	bg_busy = false


func _on_sfx(path: String, volume_db: float = 0.0) -> void:
	var audio = load(path)
	if audio == null:
		push_error("Failed to load SFX: " + path)
		return
	sfx_player.stream = audio
	sfx_player.volume_db = volume_db
	sfx_player.play()

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
	SceneManager.request_scene_change("res://scenes/chapter_1/scene_3/scene_3.tscn")

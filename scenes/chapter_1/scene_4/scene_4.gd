extends Node2D

@onready var background = $Background
@onready var curtains = get_node_or_null("Curtains")
@onready var animated_sprite = $AnimatedSprite2D
@onready var soldier_sprite = get_node_or_null("Sprite2D")
@onready var soldier_hotspot = get_node_or_null("Sprite2D/SoldierHotspot")
@onready var next_button = get_node_or_null("UI_Anchor/NextButton")
@onready var sfx_player = $SFXPlayer
@onready var hover_sfx_player = get_node_or_null("HoverSfxPlayer")
@onready var event_bus = get_node_or_null("/root/EventBus")

var current_bg: Texture2D = null
var bg_busy := false
var parser: Node
var _anim_tween: Tween
var _end_transition_started := false
@export var auto_play_anim := false
@export var auto_anim_name := "loop_5_7"
@export var static_frame_index := 6
@export var auto_advance_on_dialogue_end := false
@export var soldier_detail_image_path := "res://assets/chapter_1/scene_4/man/thirsty_soldier_single_whitebg_2.png"
@export var soldier_hover_sfx_path := ""
@export var soldier_click_sfx_path := "res://assets/general_audio/man_dying.mp3"
@export var soldier_hover_scale := 1.05

var _soldier_base_scale := Vector2.ONE
var _hover_sfx: AudioStream


func _ready():
	current_bg = load("res://assets/chapter_1/scene_4/background/tent_scene.png")
	if current_bg == null:
		push_error("Failed to load background: res://assets/chapter_1/scene_4/background/tent_scene.png")
	background.texture = current_bg
	background.visible = true
	background.modulate.a = 1.0
	background.z_index = 0
	if curtains:
		curtains.visible = false
		curtains.modulate.a = 1.0
		curtains.z_index = 3
	animated_sprite.z_index = 1
	animated_sprite.visible = false
	animated_sprite.stop()
	animated_sprite.frame = 0
	animated_sprite.modulate.a = 0.0
	if soldier_sprite:
		soldier_sprite.visible = false
		soldier_sprite.z_index = 2
		_soldier_base_scale = soldier_sprite.scale
	if next_button:
		next_button.visible = false
	if soldier_hover_sfx_path != "" and hover_sfx_player:
		_hover_sfx = load(soldier_hover_sfx_path)
	if auto_play_anim:
		_play_anim(auto_anim_name)

	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	parser.load_dialogue("res://story/chapter_1/scene_4_dialogue.json")

	if event_bus == null:
		push_error("EventBus autoload not found at /root/EventBus.")
		return
	event_bus.background_change_requested.connect(_on_bg_change)
	event_bus.play_sfx_requested.connect(_on_sfx)
	event_bus.sprite_anim_requested.connect(_on_sprite_anim_requested)
	event_bus.dialogue_finished.connect(_on_dialogue_finished)
	if soldier_hotspot and not soldier_hotspot.input_event.is_connected(_on_soldier_hotspot_input_event):
		soldier_hotspot.input_event.connect(_on_soldier_hotspot_input_event)
	if soldier_hotspot and not soldier_hotspot.mouse_entered.is_connected(_on_soldier_hotspot_mouse_entered):
		soldier_hotspot.mouse_entered.connect(_on_soldier_hotspot_mouse_entered)
	if soldier_hotspot and not soldier_hotspot.mouse_exited.is_connected(_on_soldier_hotspot_mouse_exited):
		soldier_hotspot.mouse_exited.connect(_on_soldier_hotspot_mouse_exited)
	if next_button and not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)

	parser.start()

func _on_soldier_hotspot_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if soldier_click_sfx_path != "":
			_on_sfx(soldier_click_sfx_path)
		if soldier_detail_image_path.is_empty():
			push_warning("Soldier detail image path is empty.")
			return
		if event_bus:
			event_bus.show_image_modal_requested.emit(soldier_detail_image_path)

func _on_soldier_hotspot_mouse_entered() -> void:
	if soldier_sprite:
		soldier_sprite.scale = _soldier_base_scale * soldier_hover_scale
	if hover_sfx_player and _hover_sfx:
		hover_sfx_player.stream = _hover_sfx
		hover_sfx_player.play()

func _on_soldier_hotspot_mouse_exited() -> void:
	if soldier_sprite:
		soldier_sprite.scale = _soldier_base_scale


func _on_bg_change(path: String):
	print("BG CHANGE CALLED:", path)

	if bg_busy:
		return

	bg_busy = true

	var new_bg = load(path)

	if new_bg == null:
		push_error("Failed to load: " + path)
		bg_busy = false
		return

	var tween = create_tween()

	tween.tween_property(background, "modulate:a", 0.0, 0.35)

	tween.tween_callback(func():
		background.texture = new_bg
		current_bg = new_bg
	)

	# fade in
	tween.tween_property(background, "modulate:a", 1.0, 0.35)

	# unlock AFTER animation finishes
	tween.tween_callback(func():
		bg_busy = false
	)

func _on_sfx(path: String):
	var audio = load(path)

	if audio == null:
		push_error("Failed to load SFX: " + path)
		return

	sfx_player.stream = audio
	sfx_player.play()

func _on_sprite_anim_requested(action: String, anim_name: String) -> void:
	match action:
		"play":
			_play_anim(anim_name)
		"stop":
			animated_sprite.stop()
			animated_sprite.visible = false
		"hide":
			animated_sprite.visible = false
		"show":
			animated_sprite.visible = true
		_:
			push_warning("Unknown anim action: %s" % action)

func _play_anim(anim_name: String = "") -> void:
	animated_sprite.visible = true
	animated_sprite.modulate.a = 0.0
	if _anim_tween and _anim_tween.is_running():
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.35)
	if anim_name.is_empty():
		animated_sprite.play()
	else:
		animated_sprite.play(anim_name)

func _on_dialogue_finished() -> void:
	if _end_transition_started:
		return
	_end_transition_started = true
	var final_bg = load("res://assets/chapter_1/scene_4/man/outside_tent/man_outside_tent_thirsty_drinking_8.png")
	if final_bg:
		background.texture = final_bg
		current_bg = final_bg
	animated_sprite.visible = true
	animated_sprite.modulate.a = 1.0
	animated_sprite.stop()
	animated_sprite.animation = "default"
	animated_sprite.frame = static_frame_index
	animated_sprite.visible = false
	background.visible = true
	background.modulate.a = 1.0
	if curtains:
		curtains.visible = true
	if soldier_sprite:
		soldier_sprite.visible = true
	if next_button:
		next_button.visible = true
	if auto_advance_on_dialogue_end:
		SceneManager.request_scene_change("res://scenes/chapter_1/scene_5/scene_5.tscn")

func _on_next_button_pressed() -> void:
	SceneManager.request_scene_change("res://scenes/chapter_1/scene_5/scene_5.tscn")

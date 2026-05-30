extends Node2D
class_name Scene1

@onready var next_button: TextureButton = $UI_Anchor/NextButton
@onready var transition_player: AnimationPlayer = $UI_Anchor/AnimationPlayer

var _mt_samat_glow_tween: Tween = null
var _crow_glow_tween: Tween = null
var _mt_samat_interacted: bool = false
var _crow_float_tween: Tween = null
var _crow_base_position := Vector2(950, 280)
var _crow_base_scale := Vector2(0.28, 0.28)

enum HotspotState { NONE, CROW, MT_SAMAT }
var _active_hotspot: HotspotState = HotspotState.NONE

var _narration_queue: Array = []
var _narration_index: int = 0

func _ready() -> void:
	_setup_next_button()
	next_button.visible = false
	next_button.disabled = true
	$ControlLayer/CrowButton.disabled = true
	$ControlLayer/MtSamatButton.disabled = true

	EventBus.advance_requested.connect(_on_advance_requested)
	EventBus.dialogue_finished.connect(_on_narration_finished)

	$ControlLayer/CrowButton.pressed.connect(_on_crow_clicked)
	$ControlLayer/MtSamatButton.pressed.connect(_on_mt_samat_clicked)

	transition_player.play("fade_from_black")
	await transition_player.animation_finished

	$ControlLayer/MtSamatButton.disabled = false
	_mt_samat_glow_tween = _start_glow($ControlLayer/MtSamatButton)
	_start_crow_ambient_motion()

func _start_narration(lines: Array) -> void:
	_narration_queue = lines
	_narration_index = 0
	EventBus.dialogue_requested.emit(_narration_queue[_narration_index])
	_narration_index += 1

func _on_advance_requested() -> void:
	if _narration_queue.is_empty():
		return
	if _narration_index < _narration_queue.size():
		EventBus.dialogue_requested.emit(_narration_queue[_narration_index])
		_narration_index += 1
	else:
		_narration_queue = []
		_narration_index = 0
		EventBus.dialogue_finished.emit()

func _on_narration_finished() -> void:
	match _active_hotspot:
		HotspotState.MT_SAMAT:
			_active_hotspot = HotspotState.NONE
			$ControlLayer/MtSamatButton.disabled = false
			if _mt_samat_interacted:
				$ControlLayer/CrowButton.disabled = false
				_crow_glow_tween = _start_glow($ControlLayer/CrowButton)
		HotspotState.CROW:
			transition_player.play("fade_to_black")
			await transition_player.animation_finished
			SceneManager.request_scene_change("res://scenes/chapter_1/scene_1.2/scene_1.2.tscn")
		HotspotState.NONE:
			pass

func _on_mt_samat_clicked() -> void:
	$ControlLayer/MtSamatButton.disabled = true
	$ControlLayer/CrowButton.disabled = true
	_stop_glow($ControlLayer/MtSamatButton, _mt_samat_glow_tween)
	_mt_samat_interacted = true
	_active_hotspot = HotspotState.MT_SAMAT
	_start_narration([
		{"speaker": "", "text": "The year is 1942."},
		{"speaker": "", "text": "The air is thick with ash, hunger, and fear."},
		{"speaker": "", "text": "Bataan is no longer a battlefield— It is a grave waiting to be filled."}
	])

func _on_crow_clicked() -> void:
	$ControlLayer/CrowButton.disabled = true
	$ControlLayer/MtSamatButton.disabled = true
	_stop_glow($ControlLayer/CrowButton, _crow_glow_tween)
	_active_hotspot = HotspotState.CROW
	_start_narration([
		{"speaker": "", "text": "You are standing at the edge of history."},
		{"speaker": "", "text": "Not as a witness…"},
		{"speaker": "", "text": "But as the one who must decide."}
	])

func _start_crow_ambient_motion() -> void:
	$Crow.position = Vector2(-300, 180)
	$Crow.scale = _crow_base_scale * 0.12

	var fly_tween = create_tween()
	fly_tween.tween_property($Crow, "position",
		Vector2(950, 280), 10.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var grow_tween = create_tween()
	grow_tween.tween_property($Crow, "scale",
		_crow_base_scale * 2.4, 10.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await fly_tween.finished
	_crow_float_tween = create_tween().set_loops()
	_crow_float_tween.tween_property($Crow, "position",
		Vector2(950, 280) + Vector2(-12, -16), 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_crow_float_tween.tween_property($Crow, "position",
		Vector2(950, 280) + Vector2(10, 12), 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var scale_tween = create_tween().set_loops()
	scale_tween.tween_property($Crow, "scale",
		_crow_base_scale * 2.5, 2.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scale_tween.tween_property($Crow, "scale",
		_crow_base_scale * 2.3, 2.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _start_glow(button: TextureButton) -> Tween:
	var t = create_tween().set_loops()
	t.tween_property(button, "modulate", Color(1.4, 1.2, 0.6, 1.0), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t

func _stop_glow(button: TextureButton, tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)

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

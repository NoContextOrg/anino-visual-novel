extends "res://src/gameplay/sceneTransition.gd"

@export_file("*.mp3", "*.ogg", "*.wav") var ambience_path: String = "res://assets/background/chapter_1/scene_1_2_assets/distant_war.mp3"
@export var ambience_volume_db: float = 0.0
@export var ambience_start_time: float = 3.5
@export var ambience_fade_start_db: float = -30.0
@export var ambience_fade_duration: float = 1.0
@export var dialogue_node_path: NodePath
@export var background_frame_interval: float = 0.5
@export var background_frame_paths: PackedStringArray = [
	"res://assets/chapter_1/scene_1_2/burning_on_eye_1.jpg",
	"res://assets/chapter_1/scene_1_2/burning_on_eye_2.jpg",
	"res://assets/chapter_1/scene_1_2/burning_on_eye_3.jpg",
	"res://assets/chapter_1/scene_1_2/burning_on_eye_4.jpg"
]
@export var dialogue_shake_strength: float = 6.0
@export var dialogue_shake_falloff_duration: float = 0.0
@export var dialogue_shake_background_only: bool = false
@export var end_fade_flash_color: Color = Color("FFFFFF")
@export var end_fade_flash_duration: float = 0.12
@export var end_fade_flash_to_mid_duration: float = 0.25
@export var end_fade_mid_color: Color = Color("FFEBBC")
@export var end_fade_color: Color = Color("DD6E11")
@export var end_fade_duration: float = 4
@export var end_fade_edge_softness: float = 0.5
@export var end_fade_start_radius: float = 0.005
@export var end_fade_start_softness: float = 0.2

@onready var ambience_player: AudioStreamPlayer = get_node_or_null("AmbiencePlayer")
@onready var background: TextureRect = get_node_or_null("Background")
@onready var dialogue_node: Node = get_node_or_null(dialogue_node_path)

var _end_fade_tween: Tween
var _end_fade_rect: ColorRect
var _end_fade_material: ShaderMaterial
var _end_fade_overlay: ColorRect
var _background_timer: Timer
var _background_frames: Array[Texture2D] = []
var _background_frame_index := 0
var _shake_rng := RandomNumberGenerator.new()
var _shake_time_left := 0.0
var _shake_active := false
var _shake_target: Node
var _shake_base_position := Vector2.ZERO

const _END_FADE_SHADER_CODE := """
shader_type canvas_item;

uniform float radius = 0.0;
uniform float softness = 0.12;
uniform float spike_strength = 0.08;
uniform float spike_count = 12.0;
uniform float noise_strength = 0.05;
uniform float noise_scale = 8.0;

float rand(vec2 st) {
	return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV * 2.0 - vec2(1.0);
	float dist_norm = length(uv) / 1.41421356;
	float angle = atan(uv.y, uv.x);
	float spike = sin(angle * spike_count) * spike_strength;
	float noise = (rand(uv * noise_scale) - 0.5) * 2.0 * noise_strength;
	float burst = spike + noise;
	float edge0 = clamp(radius + burst * (1.0 - radius), 0.0, 1.0);
	float edge1 = clamp(edge0 + softness, 0.0, 1.0);
	float t = smoothstep(edge0, edge1, dist_norm);
	float alpha = 1.0 - t;
	COLOR.a *= alpha;
}
"""

func _ready():
	super._ready()

	if ambience_player == null:
		ambience_player = AudioStreamPlayer.new()
		ambience_player.name = "AmbiencePlayer"
		add_child(ambience_player)

	_play_ambience()
	_connect_dialogue()
	_setup_background_animation()
	_shake_rng.randomize()

func _play_ambience() -> void:
	if ambience_path.is_empty():
		return

	var stream = load(ambience_path)
	if stream == null:
		push_error("Scene_1_2: Failed to load ambience: %s" % ambience_path)
		return

	ambience_player.stream = stream
	ambience_player.volume_db = ambience_fade_start_db
	ambience_player.play(max(ambience_start_time, 0.0))

	var tween = create_tween()
	tween.tween_property(ambience_player, "volume_db", ambience_volume_db, ambience_fade_duration)

func _setup_background_animation() -> void:
	if background == null:
		push_warning("Scene_1_2: Background node not found.")
		return

	_background_frames.clear()
	for path in background_frame_paths:
		if path.is_empty():
			continue
		var texture = load(path)
		if texture == null:
			push_warning("Scene_1_2: Missing background texture: %s" % path)
			continue
		_background_frames.append(texture)

	if _background_frames.is_empty():
		push_warning("Scene_1_2: No background frames loaded.")
		return

	_background_frame_index = 0
	background.texture = _background_frames[_background_frame_index]

	if background_frame_interval <= 0.0 or _background_frames.size() == 1:
		return

	if _background_timer == null:
		_background_timer = Timer.new()
		_background_timer.one_shot = false
		add_child(_background_timer)
		_background_timer.timeout.connect(_advance_background_frame)

	_background_timer.wait_time = background_frame_interval
	_background_timer.start()

func _advance_background_frame() -> void:
	if _background_frames.is_empty() or background == null:
		return
	_background_frame_index = (_background_frame_index + 1) % _background_frames.size()
	background.texture = _background_frames[_background_frame_index]

func _connect_dialogue() -> void:
	if dialogue_node_path == NodePath("") or dialogue_node == null:
		dialogue_node = _find_dialogue_node(self)

	if dialogue_node == null:
		push_warning("Scene_1_2: dialogue node not found. Set dialogue_node_path in the inspector.")
		return

	if not dialogue_node.has_signal("dialogue_finished"):
		push_warning("Scene_1_2: dialogue node missing dialogue_finished signal.")
		return

	var callable = Callable(self, "_on_dialogue_finished")
	if not dialogue_node.is_connected("dialogue_finished", callable):
		dialogue_node.connect("dialogue_finished", callable)

	if dialogue_node.has_signal("emphasis_shake_started"):
		var start_callable = Callable(self, "_on_dialogue_shake_started")
		if not dialogue_node.is_connected("emphasis_shake_started", start_callable):
			dialogue_node.connect("emphasis_shake_started", start_callable)

	if dialogue_node.has_signal("emphasis_shake_stopped"):
		var stop_callable = Callable(self, "_on_dialogue_shake_stopped")
		if not dialogue_node.is_connected("emphasis_shake_stopped", stop_callable):
			dialogue_node.connect("emphasis_shake_stopped", stop_callable)

func _on_dialogue_finished() -> void:
	_start_end_fade()

func _on_dialogue_shake_started() -> void:
	_start_screen_shake()

func _on_dialogue_shake_stopped() -> void:
	return

func _start_screen_shake() -> void:
	if dialogue_shake_strength <= 0.0:
		return

	if dialogue_shake_background_only and background != null:
		_shake_target = background
	else:
		_shake_target = self

	if _shake_target == null:
		return

	_shake_base_position = _shake_target.position
	_shake_time_left = 0.0
	_shake_active = true
	set_process(true)

func _stop_screen_shake() -> void:
	if not _shake_active:
		return

	_shake_active = false
	_shake_time_left = max(dialogue_shake_falloff_duration, 0.0)
	if _shake_time_left <= 0.0:
		if _shake_target != null:
			_shake_target.position = _shake_base_position
		set_process(false)

func _process(delta: float) -> void:
	if _shake_target == null:
		set_process(false)
		return

	var strength := dialogue_shake_strength
	if not _shake_active:
		if _shake_time_left <= 0.0:
			_shake_target.position = _shake_base_position
			set_process(false)
			return
		_shake_time_left = max(_shake_time_left - delta, 0.0)
		var t := 0.0
		if dialogue_shake_falloff_duration > 0.0:
			t = _shake_time_left / dialogue_shake_falloff_duration
		strength = dialogue_shake_strength * t
	var offset := Vector2(
		_shake_rng.randf_range(-strength, strength),
		_shake_rng.randf_range(-strength, strength)
	)
	if _shake_target != null:
		_shake_target.position = _shake_base_position + offset

func _start_end_fade() -> void:
	_ensure_end_fade_rect()
	_ensure_end_fade_overlay()
	_ensure_end_fade_material()
	_end_fade_rect.material = _end_fade_material
	var start_radius = clamp(end_fade_start_radius, 0.0, 1.0)
	_end_fade_material.set_shader_parameter("radius", start_radius)
	var start_softness = max(end_fade_start_softness, 0.001)
	var end_softness = max(end_fade_edge_softness, 0.001)
	_end_fade_material.set_shader_parameter("softness", start_softness)
	if _end_fade_tween and _end_fade_tween.is_running():
		_end_fade_tween.kill()

	_end_fade_rect.color = end_fade_flash_color
	var overlay_start_color := end_fade_flash_color
	overlay_start_color.a = 0.0
	_end_fade_overlay.color = overlay_start_color
	if end_fade_flash_duration <= 0.0:
		_end_fade_overlay.color = end_fade_flash_color
	if end_fade_flash_to_mid_duration <= 0.0:
		_end_fade_rect.color = end_fade_mid_color
		_end_fade_overlay.color = end_fade_mid_color

	if end_fade_duration <= 0.0:
		_end_fade_rect.color = end_fade_color
		_end_fade_overlay.color = end_fade_color
		_end_fade_material.set_shader_parameter("radius", 1.0)
		_end_fade_material.set_shader_parameter("softness", end_softness)
		return

	_end_fade_tween = create_tween()
	if end_fade_flash_duration > 0.0:
		_end_fade_tween.tween_property(_end_fade_overlay, "color", end_fade_flash_color, end_fade_flash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		_end_fade_tween.parallel().tween_property(_end_fade_rect, "color", end_fade_flash_color, end_fade_flash_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if end_fade_flash_to_mid_duration > 0.0:
		_end_fade_tween.tween_property(_end_fade_overlay, "color", end_fade_mid_color, end_fade_flash_to_mid_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_end_fade_tween.parallel().tween_property(_end_fade_rect, "color", end_fade_mid_color, end_fade_flash_to_mid_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_end_fade_tween.tween_property(_end_fade_material, "shader_parameter/radius", 1.0, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_end_fade_tween.parallel().tween_property(_end_fade_material, "shader_parameter/softness", end_softness, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_end_fade_tween.parallel().tween_property(_end_fade_rect, "color", end_fade_color, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_end_fade_tween.parallel().tween_property(_end_fade_overlay, "color", end_fade_color, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _ensure_end_fade_rect() -> void:
	if _end_fade_rect and is_instance_valid(_end_fade_rect):
		return

	_end_fade_rect = get_node_or_null("EndFadeRect")
	if _end_fade_rect == null:
		var fade_parent: Node = get_node_or_null("UI_Anchor")
		if fade_parent == null:
			fade_parent = self

		_end_fade_rect = ColorRect.new()
		_end_fade_rect.name = "EndFadeRect"
		_end_fade_rect.anchor_left = 0.0
		_end_fade_rect.anchor_top = 0.0
		_end_fade_rect.anchor_right = 1.0
		_end_fade_rect.anchor_bottom = 1.0
		_end_fade_rect.offset_left = 0.0
		_end_fade_rect.offset_top = 0.0
		_end_fade_rect.offset_right = 0.0
		_end_fade_rect.offset_bottom = 0.0
		_end_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_end_fade_rect.z_index = 1000
		fade_parent.add_child(_end_fade_rect)
	else:
		_end_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_end_fade_rect.visible = true

func _ensure_end_fade_overlay() -> void:
	if _end_fade_overlay and is_instance_valid(_end_fade_overlay):
		return

	_end_fade_overlay = get_node_or_null("EndFadeOverlay")
	if _end_fade_overlay == null:
		var fade_parent: Node = get_node_or_null("UI_Anchor")
		if fade_parent == null:
			fade_parent = self

		_end_fade_overlay = ColorRect.new()
		_end_fade_overlay.name = "EndFadeOverlay"
		_end_fade_overlay.anchor_left = 0.0
		_end_fade_overlay.anchor_top = 0.0
		_end_fade_overlay.anchor_right = 1.0
		_end_fade_overlay.anchor_bottom = 1.0
		_end_fade_overlay.offset_left = 0.0
		_end_fade_overlay.offset_top = 0.0
		_end_fade_overlay.offset_right = 0.0
		_end_fade_overlay.offset_bottom = 0.0
		_end_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_end_fade_overlay.z_index = 999
		fade_parent.add_child(_end_fade_overlay)
	else:
		_end_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_end_fade_overlay.visible = true

func _ensure_end_fade_material() -> void:
	if _end_fade_material and is_instance_valid(_end_fade_material):
		return

	var shader = Shader.new()
	shader.code = _END_FADE_SHADER_CODE
	_end_fade_material = ShaderMaterial.new()
	_end_fade_material.shader = shader

func _find_dialogue_node(root: Node) -> Node:
	for child in root.get_children():
		if child.has_signal("dialogue_finished"):
			return child
		var found = _find_dialogue_node(child)
		if found != null:
			return found
	return null

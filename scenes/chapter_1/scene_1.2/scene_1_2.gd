extends "res://src/gameplay/sceneTransition.gd"

@export_file("*.mp3", "*.ogg", "*.wav") var ambience_path: String = "res://assets/background/chapter_1/scene_1_2_assets/distant_war.mp3"
@export var ambience_volume_db: float = 0.0
@export var ambience_start_time: float = 3.5
@export var ambience_fade_start_db: float = -30.0
@export var ambience_fade_duration: float = 1.0
@export var dialogue_node_path: NodePath
@export var end_fade_mid_color: Color = Color("FFEBBC")
@export var end_fade_color: Color = Color("DD6E11")
@export var end_fade_duration: float = 4
@export var end_fade_edge_softness: float = 0.5
@export var end_fade_start_radius: float = 0.005
@export var end_fade_start_softness: float = 0.2

@onready var ambience_player: AudioStreamPlayer = get_node_or_null("AmbiencePlayer")
@onready var dialogue_node: Node = get_node_or_null(dialogue_node_path)

var _end_fade_tween: Tween
var _end_fade_rect: ColorRect
var _end_fade_material: ShaderMaterial

const _END_FADE_SHADER_CODE := """
shader_type canvas_item;

uniform float radius = 0.0;
uniform float softness = 0.12;

void fragment() {
	vec2 uv = UV * 2.0 - vec2(1.0);
	float dist_norm = length(uv) / 1.41421356;
	float edge0 = radius;
	float edge1 = radius + softness;
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

func _on_dialogue_finished() -> void:
	_start_end_fade()

func _start_end_fade() -> void:
	_ensure_end_fade_rect()
	_ensure_end_fade_material()
	_end_fade_rect.material = _end_fade_material
	var start_radius = clamp(end_fade_start_radius, 0.0, 1.0)
	_end_fade_material.set_shader_parameter("radius", start_radius)
	var start_softness = max(end_fade_start_softness, 0.001)
	var end_softness = max(end_fade_edge_softness, 0.001)
	_end_fade_material.set_shader_parameter("softness", start_softness)
	if _end_fade_tween and _end_fade_tween.is_running():
		_end_fade_tween.kill()

	_end_fade_rect.color = end_fade_mid_color

	if end_fade_duration <= 0.0:
		_end_fade_rect.color = end_fade_color
		_end_fade_material.set_shader_parameter("radius", 1.0)
		_end_fade_material.set_shader_parameter("softness", end_softness)
		return

	_end_fade_tween = create_tween()
	_end_fade_tween.tween_property(_end_fade_material, "shader_parameter/radius", 1.0, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_end_fade_tween.parallel().tween_property(_end_fade_material, "shader_parameter/softness", end_softness, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_end_fade_tween.parallel().tween_property(_end_fade_rect, "color", end_fade_color, end_fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

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

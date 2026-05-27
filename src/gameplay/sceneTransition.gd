extends Control

var _is_transitioning := false

@export var fade_out_anim: StringName = &"fade_to_black"
@export var fade_in_anim: StringName = &"fade_from_black"
@export var anim_player_path: NodePath = NodePath("UI_Anchor/AnimationPlayer")
@export var fader_path: NodePath = NodePath("UI_Anchor/Transition")
@export var fallback_fade_duration := 0.5

var anim_player: AnimationPlayer
var fader: ColorRect
var _listening := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if _is_autoload_instance():
		EventBus.scene_change_requested.connect(_on_scene_change_requested)
		_listening = true

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	if _listening and EventBus.scene_change_requested.is_connected(_on_scene_change_requested):
		EventBus.scene_change_requested.disconnect(_on_scene_change_requested)

func _on_scene_change_requested(target_path: String) -> void:
	if target_path.is_empty():
		push_warning("SceneTransition received an empty target path.")
		return
	if not is_inside_tree():
		return
	if _is_transitioning:
		return
	await _run_transition(target_path)

func _run_transition(target_path: String) -> void:
	_is_transitioning = true

	if not _resolve_nodes():
		_is_transitioning = false
		return

	await _play_fade(fade_out_anim, Color(0, 0, 0, 0))

	var tree := get_tree()
	if tree == null:
		_is_transitioning = false
		return
	var error := tree.change_scene_to_file(target_path)
	if error != OK:
		push_error("Failed to change scene: %s (%s)" % [target_path, error])
		_is_transitioning = false
		await _play_fade(fade_in_anim, Color(0, 0, 0, 1))
		return

	await tree.scene_changed
	if not _resolve_nodes():
		_is_transitioning = false
		return
	fader.color = Color(0, 0, 0, 1)
	await tree.process_frame
	await _play_fade(fade_in_anim, Color(0, 0, 0, 1))

	_is_transitioning = false

func _play_fade(anim_name: StringName, start_color: Color) -> void:
	if fader == null:
		return
	fader.color = start_color
	if anim_player != null and anim_player.has_animation(anim_name):
		anim_player.stop()
		anim_player.play(anim_name)
		await anim_player.animation_finished
		return

	var end_color := start_color
	end_color.a = 0.0 if start_color.a > 0.0 else 1.0
	var tween := create_tween()
	tween.tween_property(fader, "color", end_color, fallback_fade_duration)
	await tween.finished

func _resolve_nodes() -> bool:
	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = _find_scene_root()
	if scene_root == null:
		push_error("SceneTransition could not find the current scene.")
		return false

	anim_player = scene_root.get_node_or_null(anim_player_path)
	fader = scene_root.get_node_or_null(fader_path)

	if anim_player == null or fader == null:
		var ui_anchor := scene_root.find_child("UI_Anchor", true, false)
		if ui_anchor != null:
			if anim_player == null:
				anim_player = ui_anchor.get_node_or_null("AnimationPlayer")
			if fader == null:
				fader = ui_anchor.get_node_or_null("Transition")

	if anim_player == null or fader == null:
		_ensure_fallback_nodes(scene_root)

	if anim_player == null or fader == null:
		push_warning("SceneTransition could not find UI_Anchor nodes on the current scene.")
		return false

	return true

func _find_scene_root() -> Node:
	var root := get_tree().root
	for i in range(root.get_child_count() - 1, -1, -1):
		var child := root.get_child(i)
		if child != null and child.scene_file_path != "":
			return child
	return null

func _ensure_fallback_nodes(scene_root: Node) -> void:
	var ui_anchor := scene_root.get_node_or_null("__SceneTransitionUI")
	if ui_anchor == null:
		ui_anchor = CanvasLayer.new()
		ui_anchor.name = "__SceneTransitionUI"
		ui_anchor.layer = 10000
		scene_root.add_child(ui_anchor)

	if fader == null:
		fader = ui_anchor.get_node_or_null("Transition")
		if fader == null:
			fader = ColorRect.new()
			fader.name = "Transition"
			fader.anchor_left = 0.0
			fader.anchor_top = 0.0
			fader.anchor_right = 1.0
			fader.anchor_bottom = 1.0
			fader.offset_left = 0.0
			fader.offset_top = 0.0
			fader.offset_right = 0.0
			fader.offset_bottom = 0.0
			fader.color = Color(0, 0, 0, 0)
			fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ui_anchor.add_child(fader)

	if anim_player == null:
		anim_player = ui_anchor.get_node_or_null("AnimationPlayer")
		if anim_player == null:
			anim_player = AnimationPlayer.new()
			anim_player.name = "AnimationPlayer"
			ui_anchor.add_child(anim_player)

func _is_autoload_instance() -> bool:
	var autoload := get_node_or_null("/root/SceneTransition")
	return autoload != null and autoload == self

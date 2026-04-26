extends Control

static var _fade_in_on_ready := false
var _is_transitioning := false

@export var trigger_action: StringName = &"ui_accept"
@export var use_input_trigger := false                  
@export_file("*.tscn") var target_scene_path := ""

@onready var anim_player: AnimationPlayer = $UI_Anchor/AnimationPlayer
@onready var fader: ColorRect = $UI_Anchor/Transition

func _ready() -> void:
    fader.mouse_filter = Control.MOUSE_FILTER_IGNORE

    if _fade_in_on_ready:
        _fade_in_on_ready = false
        fader.color = Color(0, 0, 0, 1)
        fader.mouse_filter = Control.MOUSE_FILTER_STOP
        anim_player.play("fade_from_black")
        await anim_player.animation_finished
        fader.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
    if not use_input_trigger:
        return
    if target_scene_path.is_empty():
        return
    if event.is_action_pressed(trigger_action):
        transition_to_scene(target_scene_path)

func transition_to_scene(scene_path: String) -> void:
    if _is_transitioning:
        return
    _is_transitioning = true

    fader.mouse_filter = Control.MOUSE_FILTER_STOP
    anim_player.play("fade_to_black")
    await anim_player.animation_finished

    _fade_in_on_ready = true
    var error := get_tree().change_scene_to_file(scene_path)
    if error != OK:
        _fade_in_on_ready = false
        _is_transitioning = false
        fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
        push_error("Failed to change scene: %s (%s)" % [scene_path, error])


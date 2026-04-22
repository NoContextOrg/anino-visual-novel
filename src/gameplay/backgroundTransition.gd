extends TextureRect

@export var background_fade_duration := 0.35
@export var backgrounds_base_path := "res://assets/backgrounds"
@export var trigger_action: StringName = &"ui_accept"
@export var use_input_trigger := false
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp") var target_background_path := ""
@export var switch_once := true

var _overlay: TextureRect
var _has_switched := false

func _ready() -> void:
    _setup_overlay()

func _unhandled_input(event: InputEvent) -> void:
    if not use_input_trigger:
        return
    if target_background_path.is_empty():
        return
    if switch_once and _has_switched:
        return
    if not event.is_action_pressed(trigger_action):
        return

    _has_switched = true
    transition_to_location(target_background_path)

func transition_to_location(location_file: String) -> void:
    var loaded_texture := _load_background_texture(location_file)
    if loaded_texture == null:
        return
    await fade_to_texture(loaded_texture, background_fade_duration)

func set_location_instant(location_file: String) -> void:
    var loaded_texture := _load_background_texture(location_file)
    if loaded_texture == null:
        return
    set_texture_instant(loaded_texture)

func set_texture_instant(next_texture: Texture2D) -> void:
    texture = next_texture
    if _overlay != null:
        _overlay.texture = null
        _overlay.modulate.a = 0.0

func fade_to_texture(next_texture: Texture2D, duration: float) -> void:
    if _overlay == null:
        _setup_overlay()

    if _overlay == null or duration <= 0.0 or texture == null:
        set_texture_instant(next_texture)
        return

    _overlay.texture = next_texture
    _overlay.modulate.a = 0.0

    var tween := create_tween()
    tween.tween_property(_overlay, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    await tween.finished

    set_texture_instant(next_texture)

func _load_background_texture(location_file: String) -> Texture2D:
    var full_path := location_file
    if not location_file.begins_with("res://"):
        full_path = backgrounds_base_path.path_join(location_file)

    var resource := load(full_path)
    if resource == null or not (resource is Texture2D):
        push_error("Failed to load background texture: %s" % full_path)
        return null

    return resource as Texture2D

func _setup_overlay() -> void:
    var existing := get_node_or_null("BackgroundFadeOverlay")
    if existing is TextureRect:
        _overlay = existing
        _overlay.modulate.a = 0.0
        return

    _overlay = TextureRect.new()
    _overlay.name = "BackgroundFadeOverlay"
    _overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _overlay.expand_mode = expand_mode
    _overlay.stretch_mode = stretch_mode
    _overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _overlay.modulate.a = 0.0
    add_child(_overlay)
    _overlay.z_index = z_index + 1

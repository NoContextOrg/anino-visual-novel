extends TextureRect

@export var background_fade_duration := 0.8
@export var backgrounds_base_path := "res://assets/background"
@export var trigger_action: StringName = &"ui_accept"
@export var use_input_trigger := false
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp") var target_background_path := ""
@export var switch_once := true
@export var background_id_map: Dictionary = {}

const _SUPPORTED_IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp"]

var _overlay: TextureRect
var _has_switched := false
var _event_bus: Object

func _ready() -> void:
    _setup_overlay()
    _connect_event_bus()

func _exit_tree() -> void:
    _disconnect_event_bus()

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

func _on_background_change_requested(id: String) -> void:
    print("BackgroundManager: background_change_requested called with id: %s" % id)

    var resolved_path := _resolve_background_request(id)
    
    if not resolved_path.is_empty():
        transition_to_location(resolved_path)
    else:
        push_warning("BackgroundManager: Could not resolve path for ID: %s" % id)

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

func _resolve_background_request(id: String) -> String:
    var trimmed_id := id.strip_edges()
    if trimmed_id.is_empty():
        return ""

    if background_id_map.has(trimmed_id):
        var mapped_path := str(background_id_map[trimmed_id]).strip_edges()
        if mapped_path.begins_with("res://"):
            return mapped_path
        return backgrounds_base_path.path_join(mapped_path)

    if trimmed_id.begins_with("res://"):
        return trimmed_id

    if trimmed_id.begins_with("assets/"):
        return "res://%s" % trimmed_id

    if not trimmed_id.get_extension().is_empty():
        return backgrounds_base_path.path_join(trimmed_id)

    for ext in _SUPPORTED_IMAGE_EXTENSIONS:
        var candidate := backgrounds_base_path.path_join("%s.%s" % [trimmed_id, ext])
        if ResourceLoader.exists(candidate):
            return candidate

    return ""

func _connect_event_bus() -> void:
    _event_bus = get_node_or_null("/root/EventBus")
    if _event_bus == null:
        push_warning("BackgroundManager: /root/EventBus not found; background change events are disabled.")
        return
    if not _event_bus.has_signal("background_change_requested"):
        push_warning("BackgroundManager: EventBus is missing signal 'background_change_requested'.")
        return

    var callback := Callable(self, "_on_background_change_requested")
    if not _event_bus.is_connected("background_change_requested", callback):
        _event_bus.connect("background_change_requested", callback)

func _disconnect_event_bus() -> void:
    if _event_bus == null:
        return

    var callback := Callable(self, "_on_background_change_requested")
    if _event_bus.is_connected("background_change_requested", callback):
        _event_bus.disconnect("background_change_requested", callback)

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
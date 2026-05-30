extends Control

@onready var bg_anim: AnimationPlayer = $bg_animation

var _end_transition_started := false

func _ready() -> void:
    if bg_anim != null:
        bg_anim.play("table_moving")

    EventBus.dialogue_finished.connect(_on_dialogue_finished)
    
    EventBus.play_sfx_requested.connect(_on_sfx)

    Parser.load_dialogue("res://story/chapter_1/scene_3/scene_3_dialogue.json")
    Parser.start()

func _on_dialogue_finished() -> void:
    if _end_transition_started:
        return
    _end_transition_started = true
    SceneManager.request_scene_change("res://scenes/chapter_1/scene_3/map_scene_3.tscn")

func _on_sfx(path: String, volume_db: float = 0.0) -> void:
    var clean_path = path.strip_edges() 
    
    var audio = load(clean_path)
    if audio == null:
        push_error("Failed to load SFX: '" + clean_path + "'")
        return
        
    var dynamic_player = AudioStreamPlayer.new()
    dynamic_player.stream = audio
    dynamic_player.volume_db = volume_db
    
    add_child(dynamic_player)
    dynamic_player.play()
    
    dynamic_player.finished.connect(dynamic_player.queue_free)
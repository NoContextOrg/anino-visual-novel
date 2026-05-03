extends "res://src/gameplay/sceneTransition.gd"

@export_file("*.mp3", "*.ogg", "*.wav") var ambience_path: String = "res://assets/background/chapter_1/scene_1_2_assets/distant_war.mp3"
@export var ambience_volume_db: float = 0.0
@export var ambience_start_time: float = 3.5
@export var ambience_fade_start_db: float = -30.0
@export var ambience_fade_duration: float = 1.0

@onready var ambience_player: AudioStreamPlayer = get_node_or_null("AmbiencePlayer")

func _ready():
	super._ready()

	if ambience_player == null:
		ambience_player = AudioStreamPlayer.new()
		ambience_player.name = "AmbiencePlayer"
		add_child(ambience_player)

	_play_ambience()

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

extends Control

@onready var bg_anim: AnimationPlayer = $bg_animation

var _end_transition_started := false

func _ready() -> void:
	if bg_anim != null:
		bg_anim.play("table_moving")

	EventBus.dialogue_finished.connect(_on_dialogue_finished)

	Parser.load_dialogue("res://story/chapter_1/scene_3/scene_3_dialogue.json")
	Parser.start()

func _on_dialogue_finished() -> void:
	if _end_transition_started:
		return
	_end_transition_started = true
	SceneManager.request_scene_change("res://scenes/chapter_1/scene_3/map_scene_3.tscn")

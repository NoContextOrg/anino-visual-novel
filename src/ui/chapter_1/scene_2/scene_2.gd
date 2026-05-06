extends Node2D

@onready var background = $Background
@onready var sfx_player = $SFXPlayer

var current_bg: Texture2D = null
var bg_busy := false


func _ready():
	current_bg = load("res://assets/chapter_1/scene_2/background/inside_tent_bg_1.jpg")
	background.texture = current_bg

	Parser.load_dialogue("res://story/chapter_1/scene_2/scene_2_dialogue.json")
	Parser.start()

	EventBus.background_change_requested.connect(_on_bg_change)
	EventBus.play_sfx_requested.connect(_on_sfx)


func _on_bg_change(path: String):
	print("BG CHANGE CALLED:", path)

	if bg_busy:
		return

	bg_busy = true

	var new_bg = load(path)

	if new_bg == null:
		push_error("Failed to load: " + path)
		bg_busy = false
		return

	var tween = create_tween()

	tween.tween_property(background, "modulate:a", 0.0, 0.35)

	tween.tween_callback(func():
		background.texture = new_bg
		current_bg = new_bg
	)

	# fade in
	tween.tween_property(background, "modulate:a", 1.0, 0.35)

	# unlock AFTER animation finishes
	tween.tween_callback(func():
		bg_busy = false
	)

func _on_sfx(path: String):
	var audio = load(path)

	if audio == null:
		push_error("Failed to load SFX: " + path)
		return

	sfx_player.stream = audio
	sfx_player.play()

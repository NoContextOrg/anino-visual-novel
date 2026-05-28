extends Node2D

@onready var background = $Background
@onready var animated_sprite = $AnimatedSprite2D
@onready var sfx_player = $SFXPlayer
@onready var event_bus = get_node_or_null("/root/EventBus")

var current_bg: Texture2D = null
var bg_busy := false
var parser: Node
var _anim_tween: Tween


func _ready():
	current_bg = load("res://assets/background/chapter_1/scene_4_assets/tent_scene.png")
	background.texture = current_bg
	animated_sprite.visible = false
	animated_sprite.stop()
	animated_sprite.frame = 0
	animated_sprite.modulate.a = 0.0

	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	parser.load_dialogue("res://story/chapter_1/scene_4_dialogue.json")
	parser.start()

	if event_bus == null:
		push_error("EventBus autoload not found at /root/EventBus.")
		return
	event_bus.background_change_requested.connect(_on_bg_change)
	event_bus.play_sfx_requested.connect(_on_sfx)
	event_bus.sprite_anim_requested.connect(_on_sprite_anim_requested)


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

func _on_sprite_anim_requested(action: String, anim_name: String) -> void:
	match action:
		"play":
			animated_sprite.visible = true
			animated_sprite.modulate.a = 0.0
			if _anim_tween and _anim_tween.is_running():
				_anim_tween.kill()
			_anim_tween = create_tween()
			_anim_tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.35)
			if anim_name.is_empty():
				animated_sprite.play()
			else:
				animated_sprite.play(anim_name)
		"stop":
			animated_sprite.stop()
			animated_sprite.visible = false
		"hide":
			animated_sprite.visible = false
		"show":
			animated_sprite.visible = true
		_:
			push_warning("Unknown anim action: %s" % action)

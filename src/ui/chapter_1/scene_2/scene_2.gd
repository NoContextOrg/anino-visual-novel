extends Node2D

@onready var background = $Background
@onready var animation_player = $AnimationPlayer
@onready var rifle_button = $RifleButton
@onready var helmet_button = $HelmetButton
@onready var sfx_player = $SFXPlayer

var current_bg: Texture2D = null
var bg_busy := false


func _ready():
	current_bg = load("res://assets/chapter_1/scene_2/background/inside_tent_bg_1.jpg")
	background.texture = current_bg
	animation_player.play("inside_tent")

	EventBus.background_change_requested.connect(_on_bg_change)
	EventBus.play_sfx_requested.connect(_on_sfx)

	Parser.load_dialogue("res://story/chapter_1/scene_2/scene_2_dialogue.json")
	Parser.start()


func _on_bg_change(path: String):
	# rifle_button.visible = false
	# helmet_button.visible = false


	print("BG CHANGE CALLED:", path)
	animation_player.stop()

	if bg_busy:
		return

	bg_busy = true

	var new_bg = load(path)

	if new_bg == null:
		push_error("Failed to load: " + path)
		bg_busy = false
		return
	
	
	background.texture = new_bg
	current_bg = new_bg
	bg_busy = false





func _on_sfx(path: String) -> void:
	var audio = load(path)
	if audio == null:
		push_error("Failed to load SFX: " + path)
		return
	sfx_player.stream = audio
	sfx_player.play()

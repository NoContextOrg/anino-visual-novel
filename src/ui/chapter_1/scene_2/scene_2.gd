extends Node2D

@onready var background = $Background
@onready var animation_player = $AnimationPlayer
@onready var rifle_button = $RifleButton
@onready var helmet_button = $HelmetButton
@onready var sfx_player = $SFXPlayer

@export_range(0.1, 90.0, 0.1) var fade_duration: float = 2.0
var current_bg: Texture2D = null
var bg_busy := false
var fade_layer: CanvasLayer
var fade_rect: ColorRect
var fade_tween: Tween


func _ready():
	current_bg = load("res://assets/chapter_1/scene_2/background/inside_tent_bg_1.jpg")
	background.texture = current_bg
	animation_player.play("inside_tent")

	print("[DEBUG] RifleButton found: ", rifle_button)
	print("[DEBUG] HelmetButton found: ", helmet_button)
	print("[DEBUG] RifleButton script: ", rifle_button.get_script())
	print("[DEBUG] HelmetButton script: ", helmet_button.get_script())
	
	_create_fade_in_overlay()

	EventBus.background_change_requested.connect(_on_bg_change)
	EventBus.play_sfx_requested.connect(_on_sfx)

	Parser.load_dialogue("res://story/chapter_1/scene_2/scene_2_dialogue.json")
	Parser.start()


func _create_fade_in_overlay():
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	if fade_layer and is_instance_valid(fade_layer):
		fade_layer.queue_free()

	fade_layer = CanvasLayer.new()
	fade_layer.name = "FadeLayer"
	fade_layer.layer = 10
	add_child(fade_layer)

	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_layer.add_child(fade_rect)

	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), fade_duration)
	fade_tween.finished.connect(_on_fade_in_finished)


func _on_fade_in_finished() -> void:
	if fade_layer and is_instance_valid(fade_layer):
		fade_layer.queue_free()

	fade_layer = null
	fade_rect = null
	fade_tween = null

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





func _on_sfx(path: String, volume_db: float = 0.0) -> void:
	var audio = load(path)
	if audio == null:
		push_error("Failed to load SFX: " + path)
		return
	sfx_player.stream = audio
	sfx_player.volume_db = volume_db
	sfx_player.play()

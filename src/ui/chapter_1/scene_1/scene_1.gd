extends Node2D
class_name Scene1

var parser: Node

func _ready() -> void:
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	parser.load_dialogue("res://story/chapter_1/scene_1/scene_1_dialogue.json")
	parser.start()
	EventBus.dialogue_finished.connect(_on_dialogue_finished)
	# Disable hotspots until dialogue is done
	$ControlLayer/CrowButton.disabled = true
	$ControlLayer/MtSamatButton.disabled = true

func _on_dialogue_finished() -> void:
	# Enable hotspots after dialogue finishes
	$ControlLayer/CrowButton.disabled = false
	$ControlLayer/MtSamatButton.disabled = false
	# Connect button presses
	$ControlLayer/CrowButton.pressed.connect(_on_crow_clicked)
	$ControlLayer/MtSamatButton.pressed.connect(_on_mt_samat_clicked)

func _on_crow_clicked() -> void:
	EventBus.show_image_modal_requested.emit("res://assets/hotspots/chapter_1/scene_1/crow_closeup.png")

func _on_mt_samat_clicked() -> void:
	EventBus.show_image_modal_requested.emit("res://assets/hotspots/chapter_1/scene_1/mt_samat.png")

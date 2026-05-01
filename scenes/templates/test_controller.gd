extends Node

var parser

func _ready():
	print("TEST SCENE STARTED")

	EventBus.dialogue_requested.connect(_on_dialogue)
	EventBus.background_change_requested.connect(_on_bg)
	EventBus.dialogue_finished.connect(_on_finished)
	EventBus.choices_requested.connect(_on_choices)
	
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	
	parser.load_dialogue("res://story/chapter_1/dialogue.json")
	parser.start()


func _on_dialogue(data):
	print("DIALOGUE:", data)

func _on_bg(bg):
	print("BACKGROUND:", bg)

func _on_finished():
	print("FINISHED")

func _on_choices(choices):
	print("CHOICES:", choices)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("ADVANCE")
		EventBus.advance_requested.emit()
	
	if event.is_action_pressed("ui_select"):
		print("CHOICE 0")
		EventBus.choice_selected.emit(0)
	
	if event.is_action_pressed("ui_cancel"):
		print("CHOICE 1")
		EventBus.choice_selected.emit(1)

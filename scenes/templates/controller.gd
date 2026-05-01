extends Node

var parser

func _ready():
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)  # IMPORTANT
	
	parser.load_dialogue("res://story/chapter_1/dialogue.json")
	parser.start()
	EventBus.dialogue_requested.connect(_on_dialogue)
	EventBus.background_change_requested.connect(_on_bg)
	EventBus.dialogue_finished.connect(_on_end)
	EventBus.choices_requested.connect(_on_choices)

func _on_dialogue(data):
	print("DIALOGUE:", data)

func _on_bg(bg):
	print("BACKGROUND:", bg)

func _on_end():
	print("FINISHED")

func _on_choices(choices):
	print("CHOICES:", choices)
	
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Enter / Space
		EventBus.advance_requested.emit()

	if event.is_action_pressed("ui_select"):  # simulate choice 0
		EventBus.choice_selected.emit(0)

	if event.is_action_pressed("ui_cancel"):  # simulate choice 1
		EventBus.choice_selected.emit(1)

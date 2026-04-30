extends Node2D # (Or whatever type Scene2 is)

func _ready():
	# This runs the exact moment the scene finishes loading!
	Parser.load_dialogue("res://story/chapter_1/dialogue.json")
	Parser.start()

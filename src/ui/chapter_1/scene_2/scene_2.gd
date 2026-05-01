# In scene_5.gd
extends Node2D

var parser: Node

func _ready():
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	
	# Load scene-specific dialogue
	parser.load_dialogue("res://story/chapter_1/scene_2/scene_2_dialogue.json")
	
	parser.start()
	

# In scene_5.gd
extends Node2D

var parser: Node
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("Tree")

	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	add_child(parser)
	
	# Load scene-specific dialogue
	parser.load_dialogue("res://story/chapter_1/scene_5/scene_5_dialogue.json")
	
	parser.start()
	

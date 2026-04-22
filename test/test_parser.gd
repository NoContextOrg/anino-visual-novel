extends Node

func _ready():
	var parser = preload("res://src/gameplay/DialogueParser.gd").new()
	parser.load_dialogue("res://story/chapter_1/dialogue.json")
	
	print("---- START TEST ----")
	
	while true:
		var line = parser.get_next_line()
		
		if line == null:
			print("END OF FILE reached")
			break
		
		print(line["speaker"], ":", line["text"], "(", line["expression"], ")")

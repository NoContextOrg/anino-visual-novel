extends "res://addons/gut/test.gd"

var parser

func before_each():
	parser = preload("res://src/gameplay/DialogueParser.gd").new()
	parser.load_dialogue("res://story/chapter_1/dialogue.json")

func test_get_next_line_until_end():
	var count = 0
	
	while true:
		var line = parser.get_next_line()
		if line == null:
			break
		count += 1
	
	assert_gt(count, 0, "Should read at least one line")

func test_returns_null_at_end():
	# Exhaust all lines
	while parser.get_next_line() != null:
		pass
	
	var result = parser.get_next_line()
	
	assert_eq(result, null, "Should return null at end of file")

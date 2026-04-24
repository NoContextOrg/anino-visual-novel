extends Node

var chapter_id: String = ""
var line_index: int = 0

# The path where our save file will be stored on the user's computer
const SAVE_FILE_PATH = "user://dialogue_save.json"

func _ready() -> void:
	# Optional: Automatically load the game when the game boots up
	# load_game()
	pass

# Call this when the player hits a save point or quits the game
func save_game() -> void:
	var save_data = {
		"chapter_id": chapter_id,
		"line_index": line_index
	}
	
	# Open the file in WRITE mode
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		print("Game state saved! Chapter: ", chapter_id, " Line: ", line_index)
	else:
		push_error("GameManager: Failed to save game.")

# Call this from your Main Menu when the player clicks "Continue"
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found.")
		return false
		
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("GameManager: Failed to open save file. Error code: %s" % FileAccess.get_open_error())
		return false
	
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	
	if json == null:
		push_error("GameManager: Save file contains invalid JSON.")
		return false
	
	if typeof(json) != TYPE_DICTIONARY:
		push_error("GameManager: Save file has an invalid structure.")
		return false
	
	chapter_id = json.get("chapter_id", "")
	line_index = json.get("line_index", 0)
	
	print("Game state loaded! Chapter: ", chapter_id, " Line: ", line_index)
	return true

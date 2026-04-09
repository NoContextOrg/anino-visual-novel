extends Node

var flags = {
	"has_met_maxine": false,
	"has_helped_clean": true,
	"has_made_pull_request": false
}

func set_flag(key: String, value):
	flags[key] = value
	
func get_flag(key: String):
	return flags.get(key, false)

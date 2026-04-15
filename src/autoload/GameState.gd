extends Node

var _flags = {
	"has_met_maxine": false,
	"has_helped_clean": true,
	"has_made_pull_request": false
}

func _validate_flag_key(key: String) -> void:
	assert(_flags.has(key), "Unknown flag key: %s" % key)
	
func set_flag(key: String, value):
	_validate_flag_key(key)
	_flags[key] = value
	
func get_flag(key: String):
	_validate_flag_key(key)
	return _flags[key]

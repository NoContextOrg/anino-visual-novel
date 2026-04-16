extends Node

var _flags = {
	"has_met_maxine": false,
	"has_helped_clean": true,
	"has_made_pull_request": false
}

func _validate_flag_key(key: String) -> bool:
	if !_flags.has(key):
		push_error("Unknown flag key: %s" % key)
		return false
	return true
	
func set_flag(key: String, value):
	if !_validate_flag_key(key):
		return
	_flags[key] = value
	
func get_flag(key: String):
	if !_validate_flag_key(key):
		return null
	return _flags[key]

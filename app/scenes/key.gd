# The class of a button on a virtual keyboard that supports switching states, highlighting, belonging to a modifier.

extends Button

class_name KeyButton

# button data
var key_sets:Dictionary
@export var finger:TypeEngine.EFingers
@export var right_modif:bool = false
const _special = "specials"

# at the start, we set the data to the button
func set_opt(_key_sets:Dictionary):
	if _special not in button_group.resource_name and not _key_sets.is_empty():
		key_sets = _key_sets
		var value = key_sets.find_key(TypeEngine.key_simple)
		text = value if value else ""

# data for a group of symbol buttons
func on_send_group(data:String, is_right:bool = false)->bool:
	if _special == button_group.resource_name:
		if text == data and right_modif == is_right:
			button_pressed = true
			return true
	else:
		# passed a modifier to a symbolic button
		if data in key_sets.values():
			text = key_sets.find_key(data)
			return true
		# passed a character to a symbolic button
		if data in key_sets:
			button_pressed = true
			return true

	return false

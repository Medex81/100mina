# The class of a button on a virtual keyboard that supports switching states, highlighting, belonging to a modifier.

extends Button

class_name KeyButton

# button data
var _key_sets:Dictionary

# at the start, we set the data to the button
func set_opt(key_sets:Dictionary):
	_key_sets = key_sets
	# the button is symbolic
	if _key_sets.has(TypeEngine.key_simple):
		text = _key_sets[TypeEngine.key_simple].value
	else:
		# a special button with a modifier
		if not _key_sets.is_empty():
			text = _key_sets[_key_sets.keys().front()].modification
			# we reduce the font so that the name of the modifier fits on the button
			add_theme_font_size_override("font_size", 20)
# data for a group of symbol buttons
func on_symbol_group(dict:Dictionary):
	if not dict.is_empty():
		var state = dict[dict.keys().front()] as Dictionary
		# a special button on the keyboard is pressed
		if state.value.is_empty() and not _key_sets.is_empty():
			# changing the display of the symbol on the button to the usual one
			if state.modification == TypeEngine.key_simple:
				text = _key_sets[TypeEngine.key_simple].value
			else:
				# changing the display to a character with a modifier
				if _key_sets.has(state.modification):
					text = _key_sets[state.modification].value

# select a symbolic button on the virtual keyboard
func set_next_symbol(symbol:String)->bool:
	if _key_sets.has(TypeEngine.key_simple):
		for _set in _key_sets.keys():
			if _key_sets[_set].value == symbol:
				button_pressed = true
				return true
	return false

# select a special button on the virtual keyboard and return the index of the finger
func set_next_modification(mod:String, is_right:bool)->int:
	if _key_sets.has(mod) and _key_sets[mod].is_right == is_right:
		button_pressed = true
		return _key_sets[mod].finger
	return -1

# return button data by symbol without modifier
func get_key_set(symbol:String)->Dictionary:
	if _key_sets.has(TypeEngine.key_simple):
		for _set in _key_sets.keys():
			if _key_sets[_set].value == symbol:
				return _key_sets[_set]
	return {}

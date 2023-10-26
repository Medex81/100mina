extends Button

class_name KeyButton

var _key_sets:Dictionary

func set_opt(key_sets:Dictionary):
	_key_sets = key_sets
	if _key_sets.has(TypeEngine.key_simple):
		text = _key_sets[TypeEngine.key_simple].value
	else:
		if not _key_sets.is_empty():
			text = _key_sets[_key_sets.keys()[0]].modification
			add_theme_font_size_override("font_size", 20)
		
func on_symbol_group(dict:Dictionary):
	if not dict.is_empty():
		var state = dict[dict.keys()[0]] as Dictionary
		if state.value.is_empty() and not _key_sets.is_empty():
			if state.modification == TypeEngine.key_simple:
				text = _key_sets[TypeEngine.key_simple].value
			else:
				if _key_sets.has(state.modification):
					text = _key_sets[state.modification].value
			
func set_next_symbol(symbol:String)->bool:
	if _key_sets.has(TypeEngine.key_simple):
		for _set in _key_sets.keys():
			if _key_sets[_set].value == symbol:
				button_pressed = true
				return true
	return false
	
func set_next_modification(mod:String, is_right:bool)->int:
	if _key_sets.has(mod) and _key_sets[mod].is_right == is_right:
		button_pressed = true
		return _key_sets[mod].finger
	return -1

				
func get_key_set(symbol:String)->Dictionary:
	if _key_sets.has(TypeEngine.key_simple):
		for _set in _key_sets.keys():
			if _key_sets[_set].value == symbol:
				return _key_sets[_set]
	return {}

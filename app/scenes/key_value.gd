extends LineEdit

var _values:Dictionary
var _spec_buf:String = TypeEngine.key_simple

signal send_key_value_dict(dict:Dictionary)

# interception of special character input and display in the editor
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and (KEY_SPECIAL & event.keycode):
		_spec_buf = event.as_text_keycode()

func _on_text_changed(new_text):
	# Added a symbol
	if new_text.length() > _values.size():
		for symb in new_text:
			if symb not in _values:
				_values[symb] = _spec_buf
	# Removed symbol
	if new_text.length() < _values.size():
		for symb in _values:
			if symb not in new_text:
				_values.erase(symb)
		
	_spec_buf = TypeEngine.key_simple
	if spell_check(new_text):
		emit_signal("send_key_value_dict", _values)
			
func spell_check(new_text:String)->bool:
	# Check the repetitions in the characters, the characters must be unique 
	for symb in new_text:
		if new_text.count(symb) > 1:
			OS.alert(tr("key_error_val_dublicate").format([symb]), tr("key_title_error"))
			return false
	# Check repetitions in modifiers, modifiers in symbols must be unique
	var values = _values.values()
	for mod in values:
		if values.count(mod) > 1:
			OS.alert(tr("key_error_mod_dublicate").format([mod]), tr("key_title_error"))
			return false
			
	return true
		
func set_values(dict:Dictionary):
	_values = dict
	text = "".join(_values.keys())

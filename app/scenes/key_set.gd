extends VBoxContainer

class_name KeySet

var _is_in_focus = false

func _unhandled_input(event):
	if event is InputEventKey and _is_in_focus:
		if KEY_SPECIAL & event.keycode:
			$modification.text = event.as_text_keycode()
		else:
			$modification.text = TypeEngine.key_simple

func _on_value_text_changed(new_text):
	if new_text.is_empty():
		$modification.text = TypeEngine.key_simple
		
func serialize()->Dictionary:
	var res:Dictionary
	res.modification = $modification.text
	res.value = $value.text
	res.is_right = $LRSwitch/LRModif.button_pressed
	res.finger = $finger.selected
	return res
	
func deserialize(res:Dictionary):
	$modification.text = res.modification
	$value.text = res.value
	$LRSwitch/LRModif.button_pressed = res.is_right
	$finger.select(res.finger)

func _on_value_focus_entered():
	_is_in_focus = true

func _on_value_focus_exited():
	_is_in_focus = false

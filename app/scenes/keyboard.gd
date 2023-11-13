# A virtual keyboard that displays the switching of input characters and edits button data.

extends Panel

# addresses of a group of buttons: symbolic buttons and special
@export_file("*.tres") var symbols_button_path:String
@export_file("*.tres") var specials_button_path:String
var specials_button_group:ButtonGroup
var symbols_button_group:ButtonGroup
# a set of data on buttons for the keyboard
var _key_binds:Dictionary
# current button pressed
#var _selected_button:KeyButton = null
# data from the lesson scene transmitted through the data mediator to engine.gd
var _scene_data:KeyboardDataResource
# crutch. If the input sent us a symbol before the initialization of the current node, we will save the symbol and process it when ready.
var _first_symbol:String

# the signal to the fingers is highlighted in color
signal send_select_finger(index:int)

# interception of input - if a special button is pressed on the keyboard, then we will display the values on the buttons with modifiers
func _unhandled_input(event):
	if event is InputEventKey and KEY_SPECIAL & event.keycode:
		var modif = event.as_text_keycode() if event.is_pressed() else TypeEngine.key_simple
		#dict_to_buttons(symbols_button_group, modif)
		for button in symbols_button_group.get_buttons():
			button.on_send_group(modif)
	
func _ready():
	# data from the lesson scene
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource
	if _scene_data:
		# start the keyboard in character editing mode
		$key_value.visible = _scene_data.edit_mode
		$stop_type.visible = !_scene_data.edit_mode
		_key_binds = TypeEngine.load_keyboard(_scene_data.lang)
	symbols_button_group = ResourceLoader.load(symbols_button_path)
	specials_button_group = ResourceLoader.load(specials_button_path)
	symbols_button_group.pressed.connect(on_button_click)
	for button in symbols_button_group.get_buttons():
		button.set_opt(_key_binds.get(button.name, {}))
	
	if not _first_symbol.is_empty():
		_on_type_area_send_next_symbol(_first_symbol)
		
	if _scene_data.edit_mode:
		for button in specials_button_group.get_buttons():
			button.disabled = true

	
func on_button_click(button:KeyButton):
	$key_value.set_values(button.key_sets)
	if $key_value.visible:
		$key_value.grab_focus()

# select the button by the next character that the user must enter
func _on_type_area_send_next_symbol(symbol):
	if symbols_button_group:
		for symbol_button in symbols_button_group.get_buttons():
			if symbol_button.on_send_group(symbol):
				emit_signal("send_select_finger", -1)
				emit_signal("send_select_finger", symbol_button.finger)
				if specials_button_group:
					var button = specials_button_group.get_pressed_button()
					if button:
						button.button_pressed = false
					
					for spec_button in specials_button_group.get_buttons():
						if spec_button.on_send_group(symbol_button.key_sets.get(symbol, ""), symbol_button.right_modif):
							emit_signal("send_select_finger", spec_button.finger)
							break
				break
	else:
		_first_symbol = symbol

func _on_key_value_send_key_value_dict(dict:Dictionary):
	# there is a dedicated button
	var selected_button = symbols_button_group.get_pressed_button() as KeyButton
	if selected_button:
		# check for the input of duplicate values in other buttons 
		for button in symbols_button_group.get_buttons():
			if button.name != selected_button.name and not button.key_sets.is_empty():
				for new_key in dict:
					if new_key in button.key_sets and selected_button.right_modif == button.right_modif:
						OS.alert(tr("key_error_already_exists").format([new_key + " " + button.name]), tr("key_title_error"))
						return
	
		_key_binds[selected_button.name] = dict
		TypeEngine.save_keyboard(_scene_data.lang, _key_binds)
		selected_button.set_opt(dict)
	else:
		OS.alert(tr("key_error_select_key"), tr("key_title_error"))

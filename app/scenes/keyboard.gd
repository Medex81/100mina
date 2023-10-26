
extends Panel

@export_file("*.tres") var symbols_button_path:String
@export_file("*.tres") var specials_button_path:String
var specials_button_group:ButtonGroup
var symbols_button_group:ButtonGroup
var _key_binds:Dictionary
var _selected_button:KeyButton = null
var _scene_data:KeyboardDataResource
var _first_symbol:String

signal send_select_finger(index:int)

func _unhandled_input(event):
	if event is InputEventKey and KEY_SPECIAL & event.keycode:
		var dict:Dictionary
		dict.value = ""
		dict.modification = event.as_text_keycode() if event.is_pressed() else TypeEngine.key_simple
		dict_to_buttons(symbols_button_group, {event.as_text_keycode():dict})
	
func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource
	if _scene_data:
		$edit_panel.visible = _scene_data.edit_mode
		_key_binds = TypeEngine.load_keyboard(_scene_data.lang)
	symbols_button_group = ResourceLoader.load(symbols_button_path)
	specials_button_group = ResourceLoader.load(specials_button_path)
	symbols_button_group.pressed.connect(on_press_button)
	specials_button_group.pressed.connect(on_press_button)
	deserialize(_key_binds)
	if not _first_symbol.is_empty():
		_on_type_area_send_next_symbol(_first_symbol)
	
func on_press_button(button:KeyButton):
	_selected_button = button
	$edit_panel/margin/editor.deserialize(_key_binds.get(_selected_button.name, {}))
	
func dict_to_buttons(button_group:ButtonGroup, dict:Dictionary):
	for button in button_group.get_buttons():
		button.on_symbol_group(dict)

func deserialize(key_binds:Dictionary):
	for button in symbols_button_group.get_buttons():
		button.set_opt(key_binds.get(button.name, {}))
	for button in specials_button_group.get_buttons():
		button.set_opt(key_binds.get(button.name, {}))

func _on_editor_send_key_set(key_sets:Dictionary):
	if _selected_button:
		var key_sets_keys = key_sets.keys()
		for key in _key_binds.keys():
			if key != _selected_button.name:
				for key_sets_key in key_sets_keys:
					var key_old = _key_binds[key].get(key_sets_key, {})
					var key_new = key_sets[key_sets_key]
					if key_old.get("modification", "none") == key_new.modification and key_old.value == key_new.value and key_old.is_right == key_new.is_right:
						OS.alert(tr("key_opt_dublicate").format([key_sets[key_sets_key].modification + "-" + key_sets[key_sets_key].value]), tr("key_error"))
						return
		_key_binds[_selected_button.name] = key_sets
		TypeEngine.save_keyboard(_scene_data.lang, _key_binds)
		_selected_button.set_opt(key_sets)
	else:
		OS.alert(tr("key_select_key"), tr("key_error"))

func _on_type_area_send_next_symbol(symbol):
	if symbols_button_group:
		for button in symbols_button_group.get_buttons():
			if button.set_next_symbol(symbol):
				emit_signal("send_select_finger", -1)
				var dict = button.get_key_set(symbol) as Dictionary
				emit_signal("send_select_finger", dict.finger)
				if specials_button_group:
					var press_spec_btn = specials_button_group.get_pressed_button()
					if press_spec_btn:
						press_spec_btn.button_pressed = false
					var mod_finger_index = -1
					for button_mod in specials_button_group.get_buttons():
						mod_finger_index = button_mod.set_next_modification(dict.modification, dict.is_right)
						if mod_finger_index > -1:
							emit_signal("send_select_finger", mod_finger_index)
				else:
					return
	else:
		_first_symbol = symbol

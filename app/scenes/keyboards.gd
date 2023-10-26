extends VBoxContainer

var _keyboards:PackedStringArray
var _lang:String

func _ready():
	_keyboards = TypeEngine.get_keyboards()
	add_items_filtered()

func _on_remove_pressed():
	var select_id = $list.get_selected_items()
	if select_id.size() > 0:
		TypeEngine.remove_keyboard($list.get_item_text(select_id[0]))
		_keyboards = TypeEngine.get_keyboards()
		add_items_filtered()
	
func set_lang(lang:String):
	_lang = lang
	$find.text = lang
	add_items_filtered(lang)

func _on_add_pressed():
	if not _lang.is_empty():
		$list.add_item(_lang)
		TypeEngine.make_keyboard(_lang)
		_keyboards.append(_lang)

func _on_find_text_submitted(new_text):
	add_items_filtered(new_text)
	
func add_items_filtered(filter:String = ""):
	$list.clear()
	for keyboard in _keyboards:
		if filter in keyboard or filter.is_empty():
			$list.add_item(keyboard)

func _on_save_pressed():
	var select_id = $list.get_selected_items()
	if select_id.size() > 0:
		TypeEngine.save_keyboard_bind(_lang, $list.get_item_text(select_id[0]))

func _on_list_item_activated(index):
	TypeEngine.clear_keyboard_data()
	TypeEngine.keyboard_data.edit_mode = true
	TypeEngine.keyboard_data.keyboard = $list.get_item_text(index)
	get_tree().change_scene_to_file(TypeEngine.keyboard_scene)

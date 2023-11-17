# The lesson parts node, displays a list of parts, allows you to add and remove parts.

extends VBoxContainer

var _lesson:String
var _parts:Dictionary
var _lang:String

# signal to the symbol editor to display the contents of the part
signal send_part_clicked(symbols:String)

func _on_find_text_submitted(new_text):
	add_items_filtered(new_text)

func _on_add_pressed():
	if not $manage/new_part.text.is_empty() and not _lesson.is_empty():
		# the list is contained in the dictionary, the dictionary is a map that sorts keys by hash. To avoid breaking the order
		# we add an ordinal number to the beginning of each name
		var new_part = "%03d" % _parts.size() + "_" + $manage/new_part.text.to_snake_case()
		if new_part not in _parts:
			_parts[new_part] = ""
			$list.add_item(new_part)
			TypeEngine.save_lesson(_lesson, make_lesson_dict())
			get_tree().call_group(TutorStep.group_name, TutorStep.group_method, "step_sel_new_part")
	else:
		OS.alert(tr("key_error_empty_part_name"), tr("key_title_error"))
		
func make_lesson_dict()->Dictionary:
	var dict:Dictionary
	dict[TypeEngine.key_parts] = _parts
	dict[TypeEngine.key_lang] = _lang
	return dict
			
func _on_remove_pressed():
	var select_id = $list.get_selected_items() as Array
	if not select_id.is_empty():
		_parts.erase($list.get_item_text(select_id.front()))
		TypeEngine.save_lesson(_lesson, make_lesson_dict())
		add_items_filtered()
	
# fill in the list of parts from the lesson data
func set_parts(lesson:String):
	if lesson.is_empty():
		_lesson = lesson
		_parts.clear()
		_lang = ""
		$list.clear()
		return
	emit_signal("send_part_clicked", "")
	_lesson = lesson
	_parts = TypeEngine.load_lesson(lesson)
	_lang = TypeEngine.get_lesson_lang(lesson)
	add_items_filtered()
	
func add_items_filtered(filter:String = ""):
	$list.clear()
	for part in _parts.keys():
		if filter in part or filter.is_empty():
			$list.add_item(part)

# a signal to the character editor with the string it needs to display
func _on_list_item_clicked(index, _at_position, _mouse_button_index):
	emit_signal("send_part_clicked", _parts.get($list.get_item_text(index), ""))
	get_tree().call_group(TutorStep.group_name, TutorStep.group_method, "step_add_symbols")

func save_part(symbols:String):
	var select_id = $list.get_selected_items() as Array
	if not select_id.is_empty() and not _lesson.is_empty():
		_parts[$list.get_item_text(select_id.front())] = symbols
		TypeEngine.save_lesson(_lesson, make_lesson_dict())
		OS.alert(tr("key_done_part_saved"), "")
	else:
		OS.alert(tr("key_error_not_selected_part"), tr("key_title_error"))

# we start the lesson from the selected part even if we finished earlier on another one
func _on_list_item_activated(index):
	if not _lang.is_empty():
		var data = KeyboardDataResource.new()
		data.lang = _lang
		data.lesson = _lesson
		data.part = $list.get_item_text(index)
		data.symbols = _parts.get(data.part, "")
		TypeEngine.scene_mediator[TypeEngine.keyboard_scene] = data
		get_tree().change_scene_to_file(TypeEngine.keyboard_scene)
	else:
		OS.alert(tr("key_error_kb_not_exists").format([_lang]), tr("key_title_error"))


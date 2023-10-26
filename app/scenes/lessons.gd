extends VBoxContainer

var _lessons:PackedStringArray
var _lang:String

signal send_lesson_clicked(lesson:String)

func _ready():
	_on_lesson_options_send_need_update()
	var lesson = TypeEngine.get_curent_lesson_from_state()
	if not lesson.is_empty() and TypeEngine.scene_mediator.get(TypeEngine.lessons_scene, true) == true:
		start_lesson(lesson)

func _on_find_text_submitted(new_text):
	add_items_filtered(new_text)

func _on_remove_pressed():
	var select_id = $list.get_selected_items()
	if select_id.size() > 0:
		TypeEngine.remove_lesson($list.get_item_text(select_id[0]))
		_lessons = TypeEngine.get_lessons()
		add_items_filtered()
		emit_signal("send_lesson_clicked", "")
	
func add_items_filtered(filter:String = ""):
	$list.clear()
	for lesson in _lessons:
		if filter in lesson or filter.is_empty():
			$list.add_item(lesson)

func _on_list_item_clicked(index, at_position, mouse_button_index):
	_lang = TypeEngine.get_lesson_lang($list.get_item_text(index))
	emit_signal("send_lesson_clicked", $list.get_item_text(index))

func start_lesson(lesson:String):
	var parts = TypeEngine.get_lesson_parts(lesson)
	_lang = TypeEngine.get_lesson_lang(lesson)
	if not TypeEngine.is_keyboard_exists(_lang):
		OS.alert(tr("key_kb_not_exists").format([_lang, lesson]), tr("key_error"))
		return
	if parts.is_empty():
		OS.alert(tr("key_no_parts_in_lesson").format([lesson]), tr("key_error"))
		return
	var part = TypeEngine.get_part_from_state(lesson) as String
	if part.is_empty():
		part = parts.keys()[0]
	else:
		var ind_part = parts.keys().find(part)
		if ind_part == -1:
			OS.alert(tr("key_change_in_lesson").format([lesson, part]), tr("key_error"))
			return
		if ind_part < parts.keys().size() - 1:
			part = parts.keys()[ind_part + 1]
		else:
			OS.alert(tr("key_lesson_done"), tr("key_congratulations"))
			TypeEngine.set_part_to_state(lesson, "")
			return
			
	var data = KeyboardDataResource.new()
	data.lang = _lang
	data.lesson = lesson
	data.part = part
	data.symbols = parts[part]
	TypeEngine.scene_mediator[TypeEngine.keyboard_scene] = data
	get_tree().change_scene_to_file(TypeEngine.keyboard_scene)

func _on_list_item_activated(index):
	start_lesson($list.get_item_text(index))

func _on_lesson_options_send_need_update():
	_lessons = TypeEngine.get_lessons()
	add_items_filtered()

func _on_edit_kb_pressed():
	if not _lang.is_empty():
		if not TypeEngine.is_keyboard_exists(_lang):
			TypeEngine.make_keyboard(_lang)
		var data = KeyboardDataResource.new()
		data.edit_mode = true
		data.lang = _lang
		TypeEngine.scene_mediator[TypeEngine.keyboard_scene] = data
		get_tree().change_scene_to_file(TypeEngine.keyboard_scene)
	else:
		OS.alert(tr("key_select_part_or_lesson"), tr("key_error"))

func _on_file_export_dir_selected(dir):
	var select_id = $list.get_selected_items()
	if select_id.size() > 0:
		TypeEngine.export_kb_lesson($list.get_item_text(select_id[0]), dir) 

func _on_file_import_files_selected(paths:PackedStringArray):
	TypeEngine.import_kb_lesson(paths)
	_on_lesson_options_send_need_update()

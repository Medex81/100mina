# Lesson node. Displays a list of lessons, starts the lesson for execution from the first or last part completed. 

extends VBoxContainer

# list of lessons
var _lessons:PackedStringArray
# the language of the lesson, corresponds to the name of the keyboard
var _lang:String

# signal to a part to display a list of lesson parts.
signal send_lesson_clicked(lesson:String)

func _ready():
	_on_lesson_options_send_need_update()
	# starting the lesson from the last session
	var lesson = TypeEngine.get_current_lesson_from_state()
	if not lesson.is_empty() and TypeEngine.scene_mediator.get(TypeEngine.c_lessons_scene, true) == true:
		start_lesson(lesson)

# find all lessons with substring
func _on_find_text_submitted(new_text):
	add_items_filtered(new_text)

func _on_remove_pressed():
	var select_id = $list.get_selected_items() as Array
	if not select_id.is_empty():
		TypeEngine.remove_lesson($list.get_item_text(select_id.front()))
		_lessons = TypeEngine.get_lessons()
		add_items_filtered()
		emit_signal("send_lesson_clicked", "")

# output a list of lessons with a substring
func add_items_filtered(filter:String = ""):
	$list.clear()
	for lesson in _lessons:
		if filter in lesson or filter.is_empty():
			$list.add_item(lesson)

# when you click on the name of the lesson, display a list of its parts
func _on_list_item_clicked(index, _at_position, _mouse_button_index):
	_lang = TypeEngine.get_lesson_lang($list.get_item_text(index))
	emit_signal("send_lesson_clicked", $list.get_item_text(index))
	TutorStep.try_run("step_lesson_part_list")
	TutorStep.try_run("step_part_name")
	TutorStep.try_run("step_key_kb_edit")
	TutorStep.try_run("step_dialog")

func start_lesson(lesson:String):
	var lesson_dict = TypeEngine.load_lesson(lesson) as Dictionary
	if lesson_dict.is_empty():
		return
	var parts = lesson_dict.get(TypeEngine.c_key_parts, {})
	
	_lang = TypeEngine.get_lesson_lang(lesson)
	if not TypeEngine.is_keyboard_exists(_lang):
		OS.alert(tr("key_error_kb_not_exists").format([_lang, lesson]), tr("key_title_error"))
		return
	if parts.is_empty():
		OS.alert(tr("key_error_no_parts_in_lesson").format([lesson]), tr("key_title_error"))
		return
	var part = TypeEngine.get_part_from_state(lesson) as String
	var part_state = TypeEngine.get_part_state_from_state(lesson) as bool
	if part.is_empty():
		part = parts.keys().front()
	else:
		# last part id done (part_state = true) -> get next part
		if part_state:
			var ind_part = parts.keys().find(part)
			if ind_part == -1:
				OS.alert(tr("key_error_change_in_lesson").format([lesson, part]), tr("key_title_error"))
				return
			if ind_part < parts.keys().size() - 1:
				part = parts.keys()[ind_part + 1]
			else:
				OS.alert(tr("key_done_lesson"), tr("key_title_congratulations"))
				TypeEngine.set_part_to_state(lesson, "")
				return
	
	# data to the keyboard scene via the scene mediator
	var data = KeyboardDataResource.new()
	data.lang = _lang
	data.lesson = lesson
	data.part = part
	data.symbols = parts[part]
	TypeEngine.scene_mediator[TypeEngine.c_keyboard_scene] = data
	TypeEngine.set_part_to_state(lesson, part, false)
	get_tree().call_deferred("change_scene_to_file", TypeEngine.c_keyboard_scene)

# we start the lesson by double-clicking or pressing enter on the name
func _on_list_item_activated(index):
	start_lesson($list.get_item_text(index))

# you need to update the list of lessons, you may have imported lessons
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
		TypeEngine.scene_mediator[TypeEngine.c_keyboard_scene] = data
		get_tree().change_scene_to_file(TypeEngine.c_keyboard_scene)
	else:
		OS.alert(tr("key_error_select_lesson"), tr("key_title_error"))

# export the lesson and keyboard file to the specified directory
func _on_file_export_dir_selected(dir):
	var select_id = $list.get_selected_items() as Array
	if not select_id.is_empty():
		TypeEngine.export_kb_lesson($list.get_item_text(select_id.front()), dir) 

# import the specified files into the user's data and display them in the list
func _on_file_import_files_selected(paths:PackedStringArray):
	TypeEngine.import_kb_lesson(paths)
	_on_lesson_options_send_need_update()

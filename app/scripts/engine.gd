# Singleton for working with resources.

extends Node

enum EFingers{l1, l2, l3 , l4, l5, r1, r2, r3, r4, r5}
const _c_user_path = "user://"
const c_keyboards = "user://assets/keyboards/"
const c_lessons = "user://assets/lessons/"
const c_icons_path = "user://icons/"
const _c_lang_list_path = "res://app/misc/godot_lang_list.txt"
const c_keyboard_scene = "res://app/scenes/types.tscn"
const c_lessons_scene = "res://app/scenes/lessons.tscn"
const _c_state_path = _c_user_path + "state.json"
const _c_changelog = "changelog.txt"
const _c_keyboard_extension = ".kbd"
const _c_lesson_extension = ".lsn"
const _c_keyboard_version = 1
const _c_lesson_version = 1
const _c_max_string_length = 25

const _c_key_done = "done"
const c_key_simple = "Simple"
const c_key_lang = "lang"
const c_key_parts = "parts"
const _c_key_current_lesson = "curent_lesson"
const _c_key_tutors_done = "tutors_done"
const _c_key_keyboard_version = "keyboard_version"
const _c_key_lesson_version = "lesson_version"
const c_key_keys = "keys"
const _c_key_app_version = "app_version"
const _c_key_users = "users"
const _c_key_current_user = "last_user"
const _c_key_defaul_user = "Default User"
const _c_key_user_icon = "icon"
const _c_key_window_position = "window_position"
const _c_key_window_size = "window_size"
const _c_key_part = "part"
const _c_key_part_state = "part_state"

const c_app_version = 0.34

# the status of passing lessons is saved between sessions.
var _state:Dictionary
var _supported_lang_list:PackedStringArray
var _timer_post_init:Timer = null

# mediator for transferring data between scenes, the key is the name of the current scene
var scene_mediator:Dictionary

func _get_user_data(user_name:String)->Dictionary:
	var users_data = _state.get(_c_key_users, {})
	return users_data.get(user_name, {})

func _get_current_user_data()->Dictionary:
	return _get_user_data(_state.get(_c_key_current_user, _c_key_defaul_user))

func _set_current_user_data(user_data:Dictionary):
	var user_name = _state.get(_c_key_current_user, _c_key_defaul_user)
	var users_data = _state.get(_c_key_users, {})
	users_data[user_name] = user_data
	_state[_c_key_users] = users_data
	_save_state()

func set_part_to_state(lesson:String, part:String, is_done:bool = true)->bool:
	if not is_string_valid(lesson) or not is_string_valid(part):
		return false
	var user_data = _get_current_user_data()
	var lesson_data = user_data.get(lesson, {})
	lesson_data[_c_key_part] = part
	lesson_data[_c_key_part_state] = is_done
	user_data[lesson] = lesson_data
	user_data[_c_key_current_lesson] = lesson
	_set_current_user_data(user_data)
	return true

func get_part_from_state(lesson:String)->String:
	var lesson_data = _get_current_user_data().get(lesson, {})
	return lesson_data.get(_c_key_part, "")
	
func get_part_state_from_state(lesson:String)->bool:
	var lesson_data = _get_current_user_data().get(lesson, {})
	return lesson_data.get(_c_key_part_state, true)

func get_current_lesson_from_state()->String:
	return _get_current_user_data().get(_c_key_current_lesson, "")

func set_tutor_done(tutor:String)->bool:
	if not is_string_valid(tutor):
		return false
	var user_data = _get_current_user_data()
	
	var tutors_done = user_data.get(_c_key_tutors_done, []) as Array
	if tutor not in tutors_done:
		tutors_done.append(tutor)
		user_data[_c_key_tutors_done] = tutors_done
		_set_current_user_data(user_data)
	return true

func is_tutor_done(tutor:String)->bool:
	var user_data = _get_current_user_data()
	var tutors_done = user_data.get(_c_key_tutors_done, []) as Array
	return tutors_done.has(tutor)

func add_tutor(tutor_path:String, parent:Node)->bool:
	if parent and FileAccess.file_exists(tutor_path):
		var tutor_name = tutor_path.get_file().get_basename()
		for node in parent.get_children():
			if node.name == tutor_name:
				parent.remove_child(node)
				break
		var tutor_res = load(tutor_path)
		if tutor_res:
			var tutor = tutor_res.instantiate()
			if tutor:
				tutor.show()
				parent.add_child(tutor)
				return true
	return false

func _exit_tree():
	var window = get_window()
	_state[_c_key_window_position] = var_to_str(window.position)
	_state[_c_key_window_size] = var_to_str(window.size)
	_save_state()

func _ready():
	_make_dir(_c_user_path)
	_state = _load_dict(_c_state_path)
	_check_app_version(_state.get(_c_key_app_version, 0), c_app_version)
	if _c_key_current_user not in _state:
		_state[_c_key_current_user] = _c_key_defaul_user
		_state[_c_key_users] = {_c_key_defaul_user: {_c_key_tutors_done:[]}}
	_save_state()
	_timer_post_init = Timer.new()
	add_child(_timer_post_init)
	_timer_post_init.one_shot = true
	_timer_post_init.timeout.connect(init_window_position)
	_timer_post_init.start(0.5)
	
func init_window_position():
	var window = get_window()
	window.position = str_to_var(_state.get(_c_key_window_position, "Vector2i(384, 276)"))
	window.size = str_to_var(_state.get(_c_key_window_size, "Vector2i(1152, 648)"))

func _check_app_version(state_version:float, app_version:float)->bool:
	# got app update
	if state_version < app_version:
		_state[_c_key_app_version] = app_version
		# copy the built-in lessons and keyboards to the user's data
		_copy_resource("res://assets/keyboards/russian.kbd", c_keyboards)
		_copy_resource("res://assets/keyboards/english.kbd", c_keyboards)
		_copy_resource("res://assets/lessons/a_kazantsev_ru_base.lsn", c_lessons)
		_copy_resource("res://assets/lessons/a_kazantsev_en_base.lsn", c_lessons)
		_copy_resource_text("res://changelog.txt", _c_user_path)
		_save_state()
		return true
	return false

func _copy_storage(from_file_path:String, to_dir:String)->bool:
	if not _make_dir(to_dir):
		return false
	var to = to_dir.path_join(from_file_path.get_file())
	var status = DirAccess.copy_absolute(from_file_path, to)
	if status != OK:
		if not OS.is_debug_build():
			OS.alert("{0} {1} -> {2}".format([error_string(status), from_file_path, to]), tr("key_title_error"))
		return false
	return true

func _copy_resource(from_file_path:String, to_dir:String)->bool:
	if not _make_dir(to_dir):
		return false
	var dict = _load_dict(from_file_path)
	var to = to_dir.path_join(from_file_path.get_file())
	return not dict.is_empty() and _save_data(to, dict)

func _copy_resource_text(from_file_path:String, to_dir:String)->bool:
	if not _make_dir(to_dir):
		return false
	var text = _load_text(from_file_path)
	var to = to_dir.path_join(from_file_path.get_file())
	return not text.is_empty() and _save_data(to, text)

func _load_dict(path:String)->Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var status = json.parse(file.get_as_text(true))
			if status == OK:
				return json.data
	return {}

func _load_text(path:String)->String:
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path)
	return ""

func _save_data(path:String, data)->bool:
	if not _make_dir(path.get_base_dir()):
		return false
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		match type_string(typeof(data)):
			"Dictionary":
				file.store_line(JSON.stringify(data))
			"String":
				file.store_line(data)
			_:
				file.close()
				DirAccess.remove_absolute(path)
				return false
		file.flush()
		return true
	else:
		if not OS.is_debug_build():
			OS.alert("{0} -> {1}".format([error_string(FileAccess.get_open_error()), path]), tr("key_title_error"))
	return false

func export_kb_lesson(lesson:String, to_dir:String)->bool:
	return  _copy_storage(c_lessons + lesson + _c_lesson_extension, to_dir) \
	and _copy_storage(c_keyboards + get_lesson_lang(lesson) + _c_keyboard_extension, to_dir)

func import_kb_lesson(paths:PackedStringArray)->int:
	var count = 0
	for from in paths:
		if _c_keyboard_extension in from:
			_copy_storage(from, c_keyboards)
			count += 1
		if _c_lesson_extension in from:
			_copy_storage(from, c_lessons)
			count += 1
	return count

func save_keyboard(lang:String, dict:Dictionary):
	_save_data(c_keyboards + lang + _c_keyboard_extension, dict)

func load_keyboard(lang:String)->Dictionary:
	var dict = _load_dict(c_keyboards + lang + _c_keyboard_extension)
	var version = dict.get(_c_key_keyboard_version, 0)
	if version != _c_keyboard_version:
		if not OS.is_debug_build():
			OS.alert(tr("key_error_keyboard_version").format([lang + _c_keyboard_extension]), tr("key_title_error"))
	return dict

func is_keyboard_exists(lang:String)->bool:
	return FileAccess.file_exists(c_keyboards + lang + _c_keyboard_extension)

func save_lesson(lesson:String, dict:Dictionary)->bool:
	return _save_data(c_lessons + lesson + _c_lesson_extension, dict)

func load_lesson(lesson:String)->Dictionary:
	var dict = _load_dict(c_lessons + lesson + _c_lesson_extension) as Dictionary
	var version = dict.get(_c_key_lesson_version, 0)
	if version != _c_lesson_version:
		if not OS.is_debug_build():
			OS.alert(tr("key_error_lesson_version").format([lesson + _c_lesson_extension]), tr("key_title_error"))
	return dict

func _make_dir(dir_path:String)->bool:
	if not DirAccess.dir_exists_absolute(dir_path):
		var status = DirAccess.make_dir_recursive_absolute(dir_path)
		if status != OK:
			if not OS.is_debug_build():
				OS.alert("{0} -> {1}".format([error_string(status), dir_path]), tr("key_title_error"))
			return false
	return true

func get_lessons()->PackedStringArray:
	var list:PackedStringArray
	for kb in DirAccess.get_files_at(c_lessons):
		list.append(kb.get_basename())
	return list

func remove_lesson(lesson:String)->bool:
	return true if DirAccess.remove_absolute(c_lessons + lesson + _c_lesson_extension) == OK else false

func make_lesson(lesson:String, dict:Dictionary)->bool:
	dict[_c_key_lesson_version] = _c_lesson_version
	return _save_data(c_lessons + lesson + _c_lesson_extension, dict)

func make_keyboard(lang:String)->bool:
	return _save_data(c_keyboards + lang + _c_keyboard_extension, {_c_key_keyboard_version:_c_keyboard_version})

func get_supported_lang_list()->PackedStringArray:
	if _supported_lang_list.is_empty():
		var file = FileAccess.open(_c_lang_list_path, FileAccess.READ)
		if file:
			_supported_lang_list = file.get_as_text().split("\n")
		else:
			if not OS.is_debug_build():
				OS.alert("{0} -> {1}".format([error_string(FileAccess.get_open_error()), _c_lang_list_path]), tr("key_title_error"))
	return _supported_lang_list

func get_lesson_lang(lesson:String)->String:
	var dict = _load_dict(c_lessons + lesson + _c_lesson_extension) as Dictionary
	return dict.get(c_key_lang, "")

func get_changelog_path()->String:
	return _c_user_path + _c_changelog

func add_user(user_name:String)->bool:
	if not is_string_valid(user_name):
		return false
	_state[_c_key_current_user] = user_name
	var user_data = _get_current_user_data()
	if user_data.is_empty():
		user_data = {_c_key_current_lesson:""}
	_set_current_user_data(user_data)
	return true

func remove_user(user_name:String)->bool:
	if not is_string_valid(user_name):
		return false
	var users_data = _state.get(_c_key_users, {}) as Dictionary
	var user_data = users_data.get(user_name, {})
	DirAccess.remove_absolute(user_data.get(_c_key_user_icon, ""))
	users_data.erase(user_name)
	if _state[_c_key_current_user] == user_name:
		_state[_c_key_current_user] = _c_key_defaul_user
	_save_state()
	return true

func rename_user(old_name:String, new_name:String):
	var users_data = _state.get(_c_key_users, {}) as Dictionary
	var user_data = users_data.get(old_name, {}) as Dictionary
	users_data[new_name] = user_data.duplicate(true)
	_state[_c_key_users] = users_data
	var is_old_name_current = _state[_c_key_current_user] == old_name
	remove_user(old_name)
	if is_old_name_current:
		_state[_c_key_current_user] = new_name

func get_current_user()->String:
	return _state.get(_c_key_current_user, _c_key_defaul_user)

func set_current_user_icon(extern_icon_path:String = ""):
	var user_data = _get_current_user_data()
	DirAccess.remove_absolute(user_data.get(_c_key_user_icon, ""))
	if FileAccess.file_exists(extern_icon_path):
		_copy_storage(extern_icon_path, c_icons_path)
		user_data[_c_key_user_icon] = c_icons_path + extern_icon_path.get_file()
	else:
		user_data.erase(_c_key_user_icon)
	_set_current_user_data(user_data)

func _save_state():
	_save_data(_c_state_path, _state)

func get_user_icon_symbols(user_name:String)->String:
	# Default user
	var res = "DU"
	if not is_string_valid(user_name):
		return res
	var split_list = user_name.split(" ", false, 1) as Array
	match split_list.size():
		1:
			res = split_list.front().left(2)
		2:
			res = ""
			for word in split_list:
				res += word.left(1)

	return res.to_upper()

func get_current_user_icon_symbols()->String:
	return get_user_icon_symbols(_state.get(_c_key_current_user, _c_key_defaul_user))

func get_current_user_icon()->Texture:
	var user_data = _get_current_user_data()
	var tex:Texture = null
	var icon_path = user_data.get(_c_key_user_icon, "")
	if FileAccess.file_exists(icon_path):
		tex = ImageTexture.create_from_image(Image.load_from_file(icon_path))
	return tex

func get_users_list()->PackedStringArray:
	var users_data = _state.get(_c_key_users, {})
	return users_data.keys()

func is_string_valid(_str:String)->bool:
	_str = _str.strip_escapes()
	var splits = _str.split(" ", false)
	_str = " ".join(splits)
	if _str.is_empty() or _str.length() > _c_max_string_length:
		return false
	return true

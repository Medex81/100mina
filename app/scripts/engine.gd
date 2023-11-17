# Singleton for working with resources.

extends Node

enum EFingers{l1, l2, l3 , l4, l5, r1, r2, r3, r4, r5}

const _res_path = "res://"
const _user_path = "user://"
const _assets_path = "assets/"
const _game_path = "app/"
const _keyboards = "keyboards/"
const _lessons = "lessons/"
const _lang_list_path = "res://app/misc/godot_lang_list.txt"
const keyboard_scene = "res://app/scenes/types.tscn"
const lessons_scene = "res://app/scenes/lessons.tscn"

const _keyboard_extension = ".kbd"
const _lesson_extension = ".lsn"
const _cfg_extension = ".json"
const _txt_extension = ".txt"

const app_version = 0.2
const keyboard_version = 1
const lesson_version = 1

const _state = "state"
const _changelog = "changelog"
const _key_done = "done"
const key_simple = "Simple"
const key_part_symbols = "part_symbols"
const key_lang = "lang"
const key_parts = "parts"
const key_curent_lesson = "curent_lesson"
const key_tutors_done = "tutors_done"
const key_keyboard_version = "keyboard_version"
const key_lesson_version = "lesson_version"
const key_keys = "keys"
const key_app_version = "app_version"


# the status of passing lessons is saved between sessions.
var state:Dictionary
# mediator for transferring data between scenes, the key is the name of the current scene
var scene_mediator:Dictionary
var _supported_lang_list:PackedStringArray

func set_part_to_state(lesson:String, part:String):
	state[lesson] = {_key_done:part}
	state[key_curent_lesson] = lesson
	save_state()
	
func get_part_from_state(lesson:String)->String:
	var dict = state.get(lesson, {}) as Dictionary
	return dict.get(_key_done, "")
	
func get_curent_lesson_from_state()->String:
	return state.get(key_curent_lesson, "")

func set_tutor_done(tutor:String):
	var tutors_done = state.get(key_tutors_done, []) as Array
	if tutor not in tutors_done:
		tutors_done.append(tutor)
		state[key_tutors_done] = tutors_done
		save_state()

func is_tutor_done(tutor:String)->bool:
	var tutors_done = state.get(key_tutors_done, []) as Array
	return tutors_done.has(tutor)
	
func add_tutor(tutor_path:String, parent:Node):
	if parent:
		var tutor_name = tutor_path.get_file().get_basename()
		for node in parent.get_children():
			if node.name == tutor_name:
				parent.remove_child(node)
				break
		var tutor = load(tutor_path).instantiate()
		if tutor:
			tutor.show()
			parent.add_child(tutor)
	
func _ready():
	state = _load_dict_from_cfg_file(get_state_path())
	var version = state.get(key_app_version, 0)
	if version < app_version:
		state[key_app_version] = app_version
		save_state()
		# copy the built-in lessons and keyboards to the user's data
		copy_res_json_files(get_app_assets_path() + _keyboards, get_assets_path() + _keyboards)
		copy_res_json_files(get_app_assets_path() + _lessons, get_assets_path() + _lessons)
		copy_res_txt_file(_res_path + _changelog + _txt_extension, _user_path)
		
func export_kb_lesson(lesson:String, to_dir:String):
	var from = get_assets_path() + _lessons + lesson + _lesson_extension
	var to = to_dir.path_join(lesson) + _lesson_extension
	var status = DirAccess.copy_absolute(from, to)
	if status != OK:
		OS.alert("{0} {1} -> {2}".format([error_string(status), from, to, tr("key_title_error")]))
	var lang = get_lesson_lang(lesson)
	from = get_assets_path() + _keyboards + lang + _keyboard_extension
	to = to_dir.path_join(lang) + _keyboard_extension
	status = DirAccess.copy_absolute(from, to)
	if status != OK:
		OS.alert("{0} {1} -> {2}".format([error_string(status), from, to, tr("key_title_error")]))
		
func import_kb_lesson(paths:PackedStringArray):
	for from in paths:
		if _keyboard_extension in from:
			var to = get_assets_path() + _keyboards + from.get_file()
			var status = DirAccess.copy_absolute(from, to)
			if status != OK:
				OS.alert("{0} {1} -> {2}".format([error_string(status), from, to, tr("key_title_error")]))
		if _lesson_extension in from:
			var to = get_assets_path() + _lessons + from.get_file()
			var status = DirAccess.copy_absolute(from, to)
			if status != OK:
				OS.alert("{0} {1} -> {2}".format([error_string(status), from, to, tr("key_title_error")]))
	
func copy_res_json_files(from_dir:String, to_dir:String):
	make_dir(to_dir)
	var file_list = DirAccess.get_files_at(from_dir)
	for file in file_list:
		var dict = _load_dict_from_cfg_file(from_dir + file)
		_save_dict_to_cfg_file(to_dir + file, dict)
		
func copy_res_txt_file(path:String, to_dir:String):
	make_dir(to_dir)
	var text = _load_txt_file(path)
	_save_txt_file(to_dir + path.get_file(), text)

func _save_dict_to_cfg_file(path:String, dict:Dictionary):
	make_dir(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(dict))
		file.flush()
		
func _save_txt_file(path:String, text:String):
	make_dir(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(text)
		file.flush()
		
func _load_dict_from_cfg_file(path:String)->Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var status = json.parse(file.get_as_text(true))
			if status == OK:
				return json.data
	return {}
	
func _load_txt_file(path:String)->String:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			return file.get_as_text(true)
	return ""
	
func save_keyboard(lang:String, dict:Dictionary):
	var path = get_assets_path() + _keyboards + lang + _keyboard_extension
	_save_dict_to_cfg_file(path, dict)

func load_keyboard(lang:String)->Dictionary:
	var dict = _load_dict_from_cfg_file(get_assets_path() + _keyboards + lang + _keyboard_extension)
	var version = dict.get(key_keyboard_version, 0)
	if version != keyboard_version:
		OS.alert(tr("key_error_keyboard_version").format([lang + _keyboard_extension]), tr("key_title_error"))
		return {}
	else:
		return dict.get(key_keys, {})
	
func is_keyboard_exists(lang:String)->bool:
	return FileAccess.file_exists(get_assets_path() + _keyboards + lang + _keyboard_extension)

func save_lesson(lesson:String, dict:Dictionary):
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	_save_dict_to_cfg_file(path, dict)

func load_lesson(lesson:String)->Dictionary:
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	var dict = _load_dict_from_cfg_file(path) as Dictionary
	
	var version = dict.get(key_lesson_version, 0)
	if version != lesson_version:
		OS.alert(tr("key_error_lesson_version").format([lesson + _lesson_extension]), tr("key_title_error"))
		return {}
	
	return dict.get(key_parts, {})

func save_state():
	_save_dict_to_cfg_file(get_state_path(), state)

func make_dir(path:String):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

func get_app_assets_path()->String:
	var res_dir_path = _res_path + _assets_path
	make_dir(res_dir_path)
		
	if DirAccess.dir_exists_absolute(res_dir_path):
		return res_dir_path
	return ""

func get_assets_path()->String:
	var user_dir_path = _user_path + _assets_path
	make_dir(user_dir_path)
	
	if DirAccess.dir_exists_absolute(user_dir_path):
		return user_dir_path

	return ""
	
func get_state_path()->String:
	make_dir(_user_path)
	
	if DirAccess.dir_exists_absolute(_user_path):
		return _user_path + _state + _cfg_extension
	return ""
	
func get_lessons()->PackedStringArray:
	var list:PackedStringArray
	for kb in DirAccess.get_files_at(get_assets_path() + _lessons):
		list.append(kb.get_basename())
	return list
	
func get_keyboards()->PackedStringArray:
	var list:PackedStringArray
	for kb in DirAccess.get_files_at(get_assets_path() + _keyboards):
		list.append(kb.get_basename())
	return list
	
func remove_lesson(lesson:String):
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	DirAccess.remove_absolute(path)
	
func make_lesson(lesson:String, dict:Dictionary):
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	dict[key_lesson_version] = lesson_version
	_save_dict_to_cfg_file(path, dict)
	
func make_keyboard(lang:String):
	var path = get_assets_path() + _keyboards + lang + _keyboard_extension
	var dict:Dictionary
	dict[key_keyboard_version] = keyboard_version
	_save_dict_to_cfg_file(path, dict)

func remove_keyboard(lang:String):
	var path = get_assets_path() + _keyboards + lang + _keyboard_extension
	DirAccess.remove_absolute(path)

func get_supported_lang_list()->PackedStringArray:
	if _supported_lang_list.is_empty():
		var file = FileAccess.open(_lang_list_path, FileAccess.READ)
		_supported_lang_list = file.get_as_text().split("\n")
	return _supported_lang_list

func get_lesson_lang(lesson:String)->String:
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	var dict = _load_dict_from_cfg_file(path) as Dictionary
	return dict.get(key_lang, "")
	
func get_changelog_path()->String:
	return OS.get_user_data_dir().path_join(_changelog + _txt_extension)

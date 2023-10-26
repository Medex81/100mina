extends Node

enum EFingers{l1, l2, l3 , l4, l5, r1, r2, r3, r4, r5}

const _keyboard_extension = ".kbd"
const _lesson_extension = ".lsn"
const _cfg_extension = ".json"
const _res_path = "res://"
const _user_path = "user://"
const _assets_path = "assets/"
const _game_path = "app/"
const _keyboards = "keyboards/"
const _lessons = "lessons/"
const _state = "state"
const _lang_list_path = "res://app/misc/godot_lang_list.txt"
const _key_done = "done"

const key_simple = "Simple"
const keyboard_scene = "res://app/scenes/types.tscn"
const lessons_scene = "res://app/scenes/lessons.tscn"
const key_part_symbols = "part_symbols"
const key_lang = "lang"
const key_parts = "parts"
const key_curent_lesson = "curent_lesson"

var state:Dictionary
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

func _ready():
	state = _load_dict_from_cfg_file(get_state_path())
	var assets_path = get_assets_path()
	if not DirAccess.dir_exists_absolute(assets_path + _keyboards):
		make_dir(assets_path + _keyboards)
		copy_dir_recursive(get_app_assets_path() + _keyboards, assets_path + _keyboards)
	if not DirAccess.dir_exists_absolute(assets_path + _lessons):
		make_dir(assets_path + _lessons)
		copy_dir_recursive(get_app_assets_path() + _lessons, assets_path + _lessons)
		
func export_kb_lesson(lesson:String, to_dir:String):
	var from = get_assets_path() + _lessons + lesson + _lesson_extension
	var to = to_dir + "/" +lesson + _lesson_extension
	var state = DirAccess.copy_absolute(from, to)
	if state != OK:
		OS.alert(error_string(state) + " " + from + "->" + to, tr("key_error"))
	var lang = get_lesson_lang(lesson)
	from = get_assets_path() + _keyboards + lang + _keyboard_extension
	to = to_dir + "/" + lang + _keyboard_extension
	state = DirAccess.copy_absolute(from, to)
	if state != OK:
		OS.alert(error_string(state) + " " + from + "->" + to, tr("key_error"))
		
func import_kb_lesson(paths:PackedStringArray):
	for from in paths:
		if _keyboard_extension in from:
			var to = get_assets_path() + _keyboards + from.get_file()
			var state = DirAccess.copy_absolute(from, to)
			if state != OK:
				OS.alert(error_string(state) + " " + from + "->" + to, tr("key_error"))
		if _lesson_extension in from:
			var to = get_assets_path() + _lessons + from.get_file()
			var state = DirAccess.copy_absolute(from, to)
			if state != OK:
				OS.alert(error_string(state) + " " + from + "->" + to, tr("key_error"))
	
func copy_dir_recursive(from_dir:String, to_dir:String):
	var dir = DirAccess.open(from_dir)
	if dir:
		dir.list_dir_begin()
		while true:
			var next_item = dir.get_next()
			if next_item.is_empty():
				break
			if dir.current_is_dir() && next_item != "." && next_item != "..":
				DirAccess.make_dir_absolute(to_dir + "/" + next_item)
				copy_dir_recursive(dir.get_current_dir() + "/" + next_item + "/", to_dir + "/" + next_item)
			else:
				if not FileAccess.file_exists(to_dir + "/" + next_item):
					DirAccess.copy_absolute(dir.get_current_dir() + "/" + next_item, to_dir + "/" + next_item)
		dir.list_dir_end()

func _save_dict_to_cfg_file(path:String, dict:Dictionary):
	make_dir(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(dict))
		
func _load_dict_from_cfg_file(path:String)->Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json = JSON.new()
			var state = json.parse(file.get_as_text(true))
			if state == OK:
				return json.data
	return {}
	
func save_keyboard(lang:String, dict:Dictionary):
	var path = get_assets_path() + _keyboards + lang + _keyboard_extension
	_save_dict_to_cfg_file(path, dict)

func load_keyboard(lang:String)->Dictionary:
	return _load_dict_from_cfg_file(get_assets_path() + _keyboards + lang + _keyboard_extension)
	
func is_keyboard_exists(lang:String)->bool:
	return FileAccess.file_exists(get_assets_path() + _keyboards + lang + _keyboard_extension)

func save_parts(lesson:String, dict:Dictionary):
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	_save_dict_to_cfg_file(path, dict)

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
	_save_dict_to_cfg_file(path, dict)
	
func make_keyboard(lang:String):
	var path = get_assets_path() + _keyboards + lang + _keyboard_extension
	_save_dict_to_cfg_file(path, {})

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
	
func get_lesson_parts(lesson:String)->Dictionary:
	var path = get_assets_path() + _lessons + lesson + _lesson_extension
	var dict = _load_dict_from_cfg_file(path) as Dictionary
	return dict.get(key_parts, {})

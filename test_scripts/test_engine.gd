# template for test method
# func test_<script_method_name>():
# 	testing (<"comment">, <expected result>, test_script.<tested script method with return value>)

# test_script - loadind extern script
# test_dir - "user://tmp/"

extends BaseTest

# init and load testing script
func _init():
	load_test_script("res://app/scripts/engine.gd")
	if test_script:
		for prop in test_script.get_property_list():
			# no modal dialogs
			if prop.get("name", "") == "is_notif":
				test_script.is_notif = false
			# set a test path for state file
			if prop.get("name", "") == "state_path":
				test_script.state_path = test_dir + "state.json"

# ====================== TESTS ========================

func test_is_string_valid():
	const test_strings = {
		"test":true,
		"тест":true,
		"test тест":true,
		"_1 .$, 2_":true,
		"測試用戶":true,
		"\t\n":false, # skip escapes, empty string
		"":false, # empty string
		" ":false, # skip spaces, empty string
		"qwertyuiopasdfghjklzxcvbnm,.":false, # max 25 chars
		"a                           b":true} # skip spaces - "a b"
		
	for user in test_strings:
		testing(user, test_strings[user], test_script.is_string_valid(user))

func test_get_part_from_state():
	testing("empty string", "", test_script.get_part_from_state(""))
	testing("a_kazantsev_en_base", "", test_script.get_part_from_state("a_kazantsev_en_base"))
	test_script.set_part_to_state("a_kazantsev_en_base", "001_df_jk")
	testing("a_kazantsev_en_base", "001_df_jk", test_script.get_part_from_state("a_kazantsev_en_base"))

func test_get_current_lesson_from_state():
	# test data was added in the test_get_part_from_state
	testing("a_kazantsev_en_base", "a_kazantsev_en_base", test_script.get_current_lesson_from_state())

func test_is_tutor_done():
	test_script.set_tutor_done("test_tutor")
	testing("test_tutor", true, test_script.is_tutor_done("test_tutor"))
	testing("some_tutor", false, test_script.is_tutor_done("some_tutor"))

func test_add_tutor():
	testing("test_tutor, Node.new()", false, test_script.add_tutor("test_tutor", Node.new()))
	testing("res://app/scenes/key.tscn, null", false, test_script.add_tutor("res://app/scenes/key.tscn", null))
	testing("res://app/scenes/key.tscn, Node.new()", true, test_script.add_tutor("res://app/scenes/key.tscn", Node.new()))

func test__check_app_version():
	DirAccess.remove_absolute(test_script.c_keyboards + "russian.json")
	testing("check file exists 1", false, FileAccess.file_exists(test_script.c_keyboards + "russian.json"))
	testing("state = 1.1, app = 0.3", true, test_script._check_app_version(1.1, 0.3))
	testing("check file exists 2", true, FileAccess.file_exists(test_script.c_keyboards + "russian.json"))
	DirAccess.remove_absolute(test_script.c_keyboards + "russian.json")
	testing("state = 0, app = 0", false, test_script._check_app_version(0, 0))
	testing("check file exists 3", false, FileAccess.file_exists(test_script.c_keyboards + "russian.json"))
	testing("state = 0.3, app = 1.1", true, test_script._check_app_version(0.3, 1.1))
	testing("check file exists 4", true, FileAccess.file_exists(test_script.c_keyboards + "russian.json"))

func test__copy_storage():
	DirAccess.remove_absolute(test_dir + "russian.json")
	testing("check file exists->russian.json", false, FileAccess.file_exists(test_dir + "russian.json"))
	testing("russian.kbd->user://assets/tmp", true, test_script._copy_storage("user://assets/keyboards/russian.json", test_dir))
	testing("check file exists->russian.json", true, FileAccess.file_exists(test_dir + "russian.json"))

func test__copy_resource():
	DirAccess.remove_absolute(test_dir + "russian.json")
	testing("check file exists->russian.json", false, FileAccess.file_exists(test_dir + "russian.json"))
	testing("russian.kbd->test_dir", true, test_script._copy_resource("res://assets/keyboards/russian.json", test_dir))
	testing("check file exists->russian.json", true, FileAccess.file_exists(test_dir + "russian.json"))

func test__copy_resource_text():
	DirAccess.remove_absolute(test_dir + test_script._c_changelog)
	testing("check file exists->changelog.txt", false, FileAccess.file_exists(test_dir + test_script._c_changelog))
	testing("res://changelog.txt->user://assets/test", true, test_script._copy_resource_text("res://" + test_script._c_changelog, test_dir))
	testing("check file exists->changelog.txt", true, FileAccess.file_exists(test_dir + test_script._c_changelog))

func test__load_dict():
	testing("load dict->res://russian.json", false, test_script._load_dict(test_script.c_keyboards + "russian.json").is_empty())
	testing("load dict->user://russian.json", false, test_script._load_dict(test_script.c_keyboards + "russian.json").is_empty())
	testing("load dict->user://changelog.txt", true, test_script._load_dict(test_script._c_user_path + test_script._c_changelog).is_empty())

func test__save_data():
	testing("save dict", true, test_script._save_data(test_dir + "dict.json", {1:2}))
	testing("save str", true, test_script._save_data(test_dir + "str.txt", "test save"))
	testing("save int", false, test_script._save_data(test_dir + "int.data", 1))

func test_export_kb_lesson():
	testing("export lesson and kb", true, test_script.export_kb_lesson("a_kazantsev_ru_base", test_dir.path_join("export")))
	testing("export2 lesson and kb", false, test_script.export_kb_lesson("a_kazantsev", test_dir.path_join("export")))

func test_load_keyboard():
	testing("load exists kb", false, test_script.load_keyboard("russian").is_empty())
	testing("load not exists kb", true, test_script.load_keyboard("kazakstan").is_empty())

func test_is_keyboard_exists():
	testing("exists russian kb", true, test_script.is_keyboard_exists("russian"))

func test__make_dir():
	testing("mk dir", true, test_script._make_dir(test_dir.path_join("mk_dir_test")))
	testing("mk dir same", true, test_script._make_dir(test_dir.path_join("mk_dir_test")))

func test_get_supported_lang_list():
	testing("lang list", false, test_script.get_supported_lang_list().is_empty())

func test_get_lesson_lang():
	testing("get lang from a_kazantsev_ru_base", "russian", test_script.get_lesson_lang("a_kazantsev_ru_base"))
	testing("get lang from a_kazantsev", "", test_script.get_lesson_lang("a_kazantsev"))
	
func test_add_user():
	testing("add test user->current", true, test_script.add_user("test_user"))
	testing("check test user->current", "test_user", test_script.get_current_user())
	testing("check test user data", false, test_script._get_current_user_data().is_empty())
	
func test_rename_user():
	test_script.rename_user("test_user", "new_test_user")
	testing("check new test user->current", "new_test_user", test_script.get_current_user())
	testing("check test old user data not exist", true, test_script._get_user_data("test_user").is_empty())
	
func test_remove_user():
	testing("remove new test user", true, test_script.remove_user("new_test_user"))
	testing("check new test user not current", false, test_script.get_current_user() == "new_test_user")
	testing("check test new user data not exist", true, test_script._get_user_data("new_test_user").is_empty())

func test_set_current_user_icon():
	test_script.set_current_user_icon("res://assets/textures/app_icons/icon.jpg")
	var user_data = test_script._get_current_user_data()
	testing("user icon exist in storage", true, FileAccess.file_exists(user_data.get(test_script._c_key_user_icon, "")))
	
func test_get_current_user_icon():
	testing("load from storage user icon", true, test_script.get_current_user_icon() != null)

func test_get_user_icon_symbols():
	testing("user symbols empty", "DU", test_script.get_user_icon_symbols("")) # Default user
	testing("user symbols one word", "1T", test_script.get_user_icon_symbols("1test"))
	testing("user symbols two word", "NS", test_script.get_user_icon_symbols("Nik Ser Vik"))
	testing("user symbols someshit", "1_", test_script.get_user_icon_symbols("1 _"))
	

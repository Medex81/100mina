# add this script to the autoload if you wont start unit tests or run by hands
extends Node

var test_scripts:Dictionary
var result:Dictionary
# default path for a unit tests
const path_to_tests = "res://test_scripts/"

func _ready():
	DirAccess.make_dir_absolute(path_to_tests)
	start_tests(path_to_tests)

func start_tests(tests_dir:String):
	if tests_dir.is_empty():
		return
	for test_script_name in DirAccess.get_files_at(tests_dir):
		test_scripts[test_script_name] = load(tests_dir + test_script_name).new()
		
	print("===================================== Unit tests ==========================================")
	for test_script_name in test_scripts:
		result[test_script_name] = test_scripts[test_script_name].start_tests()
		if result[test_script_name].is_empty() or result[test_script_name].get(BaseTest.test_error, 1) != 0:
			var methods_dict = result[test_script_name].get(BaseTest.test_methods_key, {})
			for method in methods_dict:
				for test in methods_dict[method]:
					if test.get(BaseTest.test_state_key, "") == BaseTest.test_error:
						printerr("test script [{0}], script [{1}], method [{2}], error [{3}]".format([test_script_name, result[test_script_name].get(BaseTest.test_block_key, "none"), method, test]))
		else:
			print("All tests done!")

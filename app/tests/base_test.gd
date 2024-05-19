extends Node

class_name BaseTest

const test_passed = "PASSED"
const test_error = "ERROR"
const test_block_key = "testing"
const test_state_key = "state"
const test_input_key = "input"
const test_expected_key = "expected"
const test_output_key = "output"
const test_passed_counter = "passed counter"
const test_error_counter = "error counter"
const test_total = "total tests"
const test_name_key = "name"
const test_methods_key = "methods"
const test_test_method_prefix = "test_"
const test_dir = "user://tmp/"

var passed_counter = 0
var error_counter = 0
var script_name:String
var test_script = null
var result:Dictionary
var tmp_result:Array


func load_test_script(path:String)->bool:
	script_name = path.get_file()
	test_script = load(path).new()
	result[test_block_key] = script_name
	return test_script != null
	
func start_tests()->Dictionary:
	if test_script:
		var methods_dict:Dictionary
		for dict in get_method_list():
			var _name = dict.get(test_name_key, "")
			if _name.begins_with(test_test_method_prefix):
				tmp_result.clear()
				call(_name)
				methods_dict[_name.trim_prefix(test_test_method_prefix)] = tmp_result.duplicate()
		result[test_methods_key] = methods_dict
		result[test_passed] = passed_counter
		result[test_error] = error_counter
		result[test_total] = passed_counter + error_counter
	return result
	
func testing(input, expected, output):
	var is_passed = test_error
	if expected == output:
		is_passed = test_passed
		passed_counter += 1
	else:
		error_counter += 1
	tmp_result.append({test_state_key:is_passed, test_input_key:input, test_expected_key:expected, test_output_key:output})

extends HBoxContainer

@export_file("*.*scn") var key_opt:String

var _key_opt_res:PackedScene

signal send_key_set(key_sets)

func _ready():
	if not key_opt.is_empty():
		_key_opt_res = load(key_opt)

func _on_add_pressed():
	if _key_opt_res:
		$key_sets.add_child(_key_opt_res.instantiate())
	else:
		OS.alert(tr("key_need_key_opt"), tr("key_error"))

func _on_remove_pressed():
	remove(-1)
		
func remove(index:int)->bool:
	if $key_sets.get_child_count() and index < $key_sets.get_child_count():
		var last_child = $key_sets.get_children()[index]
		$key_sets.remove_child(last_child)
		last_child.queue_free()
		return true
	return false

func _on_save_pressed():
	var _key_sets:Dictionary
	var is_func_key = false
	var is_sign_key = false
	for child in $key_sets.get_children():
		if child is KeySet:
			var key_set_res = child.serialize() 
			if _key_sets.has(key_set_res.modification):
				OS.alert(tr("key_already_exists").format([key_set_res.modification]), tr("key_error"))
				return
			if key_set_res.modification == TypeEngine.key_simple and key_set_res.value.is_empty():
				OS.alert(tr("key_empty_simple").format([key_set_res.modification]), tr("key_error"))
				return
			if key_set_res.value.is_empty():
				if is_func_key:
					OS.alert(tr("key_one_func_set"), tr("key_error"))
					return
				if is_sign_key:
					OS.alert(tr("key_only_one_type"), tr("key_error"))
					return
				is_func_key = true
			if key_set_res.modification == TypeEngine.key_simple and not key_set_res.value.is_empty() and is_func_key:
				OS.alert(tr("key_only_one_type"), tr("key_error"))
				return
			if key_set_res.modification == TypeEngine.key_simple and not key_set_res.value.is_empty():
				is_sign_key = true
			_key_sets[key_set_res.modification] = key_set_res
		else:
			OS.alert(tr("key_only_keyset"), tr("key_error"))
			return
				
	emit_signal("send_key_set", _key_sets)

func deserialize(dict:Dictionary):
	while remove(-1):
		pass
	if _key_opt_res:
		for key in dict.keys():
			var key_set = _key_opt_res.instantiate() as KeySet
			key_set.deserialize(dict[key])
			$key_sets.add_child(key_set)

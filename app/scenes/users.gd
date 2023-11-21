extends Panel

var _select_user = -1

signal send_change_current_user()

func _ready():
	update()
	set_current_user_icon_symbols()
	
func set_visibility():
	visible = !visible
	
func update():
	$MarginContainer/VBoxContainer/user_list.clear()
	for user in TypeEngine.get_users_list():
		$MarginContainer/VBoxContainer/user_list.add_item(user)
	
func set_current_user_icon_symbols():
	$MarginContainer/VBoxContainer/icon.set_symbols(TypeEngine.get_current_user_icon_symbols())
	$MarginContainer/VBoxContainer/icon.set_texture(TypeEngine.get_user_icon(TypeEngine.get_current_user()))
	$MarginContainer/VBoxContainer/user_name.text = TypeEngine.get_current_user()

func _on_rename_pressed():
	if _select_user > -1:
		var new_user_name = $MarginContainer/VBoxContainer/edit_user/user_name.text
		var old_user_name = $MarginContainer/VBoxContainer/user_list.get_item_text(_select_user)
		if new_user_name.is_valid_filename():
			TypeEngine.rename_user(old_user_name, new_user_name)
			TypeEngine.set_current_user(new_user_name)
			update()
			set_current_user_icon_symbols()
		else:
			OS.alert(tr("key_error_username"), tr("key_title_error"))
	else:
		OS.alert(tr("key_error_user_select"), tr("key_title_error"))

func _on_user_list_item_clicked(index, at_position, mouse_button_index):
	_select_user = index
	var user_name = $MarginContainer/VBoxContainer/user_list.get_item_text(_select_user)
	TypeEngine.set_current_user(user_name)
	set_current_user_icon_symbols()
	emit_signal("send_change_current_user")

func _on_add_pressed():
	var new_user_name = $MarginContainer/VBoxContainer/edit_user/user_name.text
	if new_user_name.is_valid_filename():
		TypeEngine.add_user(new_user_name)
		TypeEngine.set_current_user(new_user_name)
		update()
		set_current_user_icon_symbols()
	else:
		OS.alert(tr("key_error_username"), tr("key_title_error"))

func _on_remove_pressed():
	if _select_user > -1:
		var user_name = $MarginContainer/VBoxContainer/edit_user/user_name.text
		TypeEngine.remove_user($MarginContainer/VBoxContainer/user_list.get_item_text(_select_user))
		update()
		set_current_user_icon_symbols()
		emit_signal("send_change_current_user")

func _on_icon_send_change_icon():
	emit_signal("send_change_current_user")

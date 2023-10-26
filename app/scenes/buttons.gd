extends VBoxContainer

signal send_click_help_button(button_name:String)


func _on_about_pressed():
	emit_signal("send_click_help_button", $about.name)

func _on_version_pressed():
	emit_signal("send_click_help_button", $version.name)

func _on_vk_pressed():
	emit_signal("send_click_help_button", "")

func _on_create_lesson_pressed():
	emit_signal("send_click_help_button", $create_lesson.name)

func _on_create_keyboard_pressed():
	emit_signal("send_click_help_button", $create_keyboard.name)

func _on_export_pressed():
	emit_signal("send_click_help_button", $export.name)

func _on_import_pressed():
	emit_signal("send_click_help_button", $import.name)

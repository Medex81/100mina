extends HBoxContainer

var _state = false

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_E:
				_state = !_state
				edit_state(_state)

func edit_state(state:bool):
	#$keyboards.visible = state
	$chapter.visible = state
	$lessons/manage.visible = state
	$parts/manage.visible = state

#func _on_lang_send_lang_clicked(lang:String):
#	$lessons.set_lang(lang)
#	$keyboards.set_lang(lang)
#
func _on_lessons_send_lesson_clicked(lesson:String):
	$parts.set_parts(lesson)

func _on_parts_send_part_clicked(symbols:String):
	$chapter.set_symbols(symbols)

func _on_chapter_send_chapter_save(symbols):
	$parts.save_part(symbols)

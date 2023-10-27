# Mediator for lesson nodes, parts and symbols

extends HBoxContainer

var _state = false

# edit mode switch
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_E:
				_state = !_state
				edit_state(_state)

func edit_state(state:bool):
	$chapter.visible = state
	$lessons/manage.visible = state
	$parts/manage.visible = state

func _on_lessons_send_lesson_clicked(lesson:String):
	$parts.set_parts(lesson)

func _on_parts_send_part_clicked(symbols:String):
	$chapter.set_symbols(symbols)

func _on_chapter_send_chapter_save(symbols):
	$parts.save_part(symbols)

extends VBoxContainer

var _lesson:String


func _on_export_pressed():
	if not _lesson.is_empty():
		$file_export.visible = true
	else:
		OS.alert(tr("key_error_select_lesson"), tr("key_title_error"))

func _on_import_pressed():
	$file_import.visible = true


func _on_lessons_send_lesson_clicked(lesson):
	_lesson = lesson

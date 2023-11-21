extends VBoxContainer

var _lesson:String

func _ready():
	set_current_user_icon_symbols()
	
func set_current_user_icon_symbols():
	$user/user_icon.set_symbols(TypeEngine.get_current_user_icon_symbols())
	$user/user_icon.set_texture(TypeEngine.get_user_icon(TypeEngine.get_current_user()))

func _on_export_pressed():
	if not _lesson.is_empty():
		$file_export.visible = true
	else:
		OS.alert(tr("key_error_select_lesson"), tr("key_title_error"))

func _on_import_pressed():
	$file_import.visible = true

func _on_lessons_send_lesson_clicked(lesson):
	_lesson = lesson

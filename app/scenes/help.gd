extends Panel

@export_file("*.tscn") var create_lesson:String
@export_file("*.tscn") var create_keyboard:String

func _ready():
	$margin/VBoxContainer/version.text = tr("key_title_version").format([TypeEngine.version])

func _on_pressed():
	hide()

func _on_create_lesson_pressed():
	_on_pressed()
	if not create_lesson.is_empty():
		TypeEngine.add_tutor(create_lesson, get_tree().current_scene)

func _on_create_keyboard_pressed():
	_on_pressed()
	if not create_keyboard.is_empty():
		TypeEngine.add_tutor(create_keyboard, get_tree().current_scene)

func _on_export_pressed():
	_on_pressed()

func _on_import_pressed():
	_on_pressed()

func _on_help_pressed():
	visible = !visible
	

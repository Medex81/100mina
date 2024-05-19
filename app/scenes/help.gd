extends Panel

@export_file("*.tscn") var create_lesson:String
@export_file("*.tscn") var create_keyboard:String
@export_file("*.tscn") var export:String
@export_file("*.tscn") var import:String

func _ready():
	$margin/VBoxContainer/version.text = tr("key_title_version").format([TypeEngine.c_app_version])

func _on_pressed():
	hide()

func _on_create_lesson_pressed():
	_on_pressed()
	if not create_lesson.is_empty():
		TypeEngine.add_tutor(create_lesson, get_tree().current_scene.get_node("main"))

func _on_create_keyboard_pressed():
	_on_pressed()
	if not create_keyboard.is_empty():
		TypeEngine.add_tutor(create_keyboard, get_tree().current_scene.get_node("main"))

func _on_export_pressed():
	_on_pressed()
	if not export.is_empty():
		TypeEngine.add_tutor(export, get_tree().current_scene.get_node("main"))

func _on_import_pressed():
	_on_pressed()
	if not import.is_empty():
		TypeEngine.add_tutor(import, get_tree().current_scene.get_node("main"))

func _on_help_pressed():
	visible = !visible
	

func _on_changelog_pressed():
	_on_pressed()
	OS.shell_open(TypeEngine.get_changelog_path())

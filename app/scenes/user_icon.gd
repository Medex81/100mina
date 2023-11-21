extends Panel

class_name UserIcon

@export var show_gear:bool = true

signal send_change_icon()

func _ready():
	$edit_icon.visible = show_gear
	$user_image_dlg.get_cancel_button().pressed.connect(_on_cancel_pressed)

func set_symbols(symbols:String):
	$label.text = symbols
	
func set_texture(texture:Texture):
	$icon.texture = texture

func _on_edit_icon_pressed():
	$user_image_dlg.show()
	
func _on_cancel_pressed():
	TypeEngine.set_user_icon(TypeEngine.get_current_user(), "")
	$icon.texture = null
	emit_signal("send_change_icon")

func _on_user_image_dlg_file_selected(path:String):
	var icon_path = TypeEngine.save_to_user_dir(path, TypeEngine.icons_path, TypeEngine.get_current_user())
	if not icon_path.is_empty():
		TypeEngine.set_user_icon(TypeEngine.get_current_user() ,icon_path.get_file())
		$icon.texture = TypeEngine.get_user_icon(TypeEngine.get_current_user())
		emit_signal("send_change_icon")

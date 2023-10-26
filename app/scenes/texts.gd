extends VBoxContainer


func on_press_button(button_name:String):
	for child in get_children():
		child.visible = true if child.name == button_name else false

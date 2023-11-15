extends ReferenceRect

@export var is_handle_key:bool = false

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		hide_step()
			
func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and is_handle_key == true and visible == true:
		hide_step()

func hide_step():
	if get_parent() is TutorStep:
		get_parent().hide_step()

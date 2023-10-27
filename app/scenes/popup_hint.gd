extends Panel


func _ready():
	visible = !TypeEngine.get_hide_hint_to_state()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and visible:
		TypeEngine.set_hide_hint_to_state()
		hide()

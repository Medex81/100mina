# A hint at the start for the user. It appears once and after clicking on it is no longer displayed.
# It seems that launching by double-clicking on the name of the lesson or part is not obvious.

extends Panel

func _ready():
	visible = !TypeEngine.get_hide_hint_to_state()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and visible:
		TypeEngine.set_hide_hint_to_state()
		hide()

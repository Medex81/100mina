# Displaying the fingers with which you need to press the key by zones

extends Control

# Index from enum to engine.gd corresponds to the node index. The index is taken from the keyboard data specified when it was created.
# -1 deselect.
func _on_keyboard_send_select_finger(index):
	if index == -1:
		for finger in $Control.get_children():
			finger.default_color = Color.WHITE
	else:
		$Control.get_child(index).default_color = Color.GREEN
	


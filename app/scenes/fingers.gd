extends Control

var _scene_data:KeyboardDataResource

func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource

func _on_keyboard_send_select_finger(index):
	if index == -1:
		for finger in $Control.get_children():
			finger.default_color = Color.WHITE
	else:
		$Control.get_child(index).default_color = Color.GREEN
	


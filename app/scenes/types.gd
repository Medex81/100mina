extends Control

@export_file("*.tscn") var new_kb_tutor:String
var _scene_data:KeyboardDataResource

func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource
	if _scene_data and not _scene_data.edit_mode:
		$margin/help.hide()
		
	if not new_kb_tutor.is_empty() and not TypeEngine.is_tutor_done(new_kb_tutor.get_file().get_basename()):
		help_tutor()
		
func help_tutor():
	TypeEngine.add_tutor(new_kb_tutor, $margin/vbox/keyboards/keyboard)

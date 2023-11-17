extends Control

@export_file("*.tscn") var new_kb_tutor:String
@export_file("*.tscn") var keyboard_start_tutor:String
var _scene_data:KeyboardDataResource

func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource
	if _scene_data:
		state(_scene_data.edit_mode)
		if _scene_data.edit_mode:
			if not new_kb_tutor.is_empty():
				help_tutor()
		else:
			if not keyboard_start_tutor.is_empty() and not TypeEngine.is_tutor_done(keyboard_start_tutor.get_file().get_basename()):
				TypeEngine.add_tutor(keyboard_start_tutor, self)
		
func state(mode:bool):
	$help.visible = mode
	$fingers.visible = !mode
		
func help_tutor():
	TypeEngine.add_tutor(new_kb_tutor, self)

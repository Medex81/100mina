extends Control

@export_file("*.tscn") var new_kb_tutor:String

func _ready():
	if not new_kb_tutor.is_empty() and not TypeEngine.is_tutor_done(new_kb_tutor.get_file().get_basename()):
		help_tutor()
		
func help_tutor():
	TypeEngine.add_tutor(new_kb_tutor, get_tree().current_scene)

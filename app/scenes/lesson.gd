extends Control

@export_file("*.tscn") var start_tutor:String

func _ready():
	if not start_tutor.is_empty() and not TypeEngine.is_tutor_done(start_tutor.get_file().get_basename()):
		TypeEngine.add_tutor(start_tutor, get_tree().current_scene)

# Node for user input of characters

extends Panel

@export_file("*.wav") var _sound_error:String
@export_file("*.wav") var _sound_success:String

# data from the lesson scene with startup parameters
var _scene_data:KeyboardDataResource

# the signal for the selection of a button and a finger
signal send_next_symbol(symbol:String)

func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.keyboard_scene, null) as KeyboardDataResource
	if _scene_data:
		$HBoxContainer/input.text = _scene_data.symbols
		emit_signal("send_next_symbol", $HBoxContainer/input.text.left(1))
		if _scene_data.edit_mode:
			hide()
	$HBoxContainer/accept.grab_focus()
	
func _on_accept_text_changed(new_text:String):
	if new_text.is_empty():
		return
		
	# the character entered is expected = delete the character and highlight the next one
	if new_text == $HBoxContainer/input.text.left(1):
		$HBoxContainer/input.text = $HBoxContainer/input.text.erase(0)
		emit_signal("send_next_symbol", $HBoxContainer/input.text.left(1))
	else:
		play_sound(_sound_error)
	$HBoxContainer/accept.clear()
	
	# part passed
	if _scene_data and $HBoxContainer/input.text.is_empty():
		$HBoxContainer/input.text = ""
		play_sound(_sound_success)
		$Timer.start()

# go to the lesson scene after completing character input and clearing the screen.
# pass the flag of the successful completion of the part to the lesson scene, with it the next part automatically starts.
func _on_timer_timeout():
	TypeEngine.set_part_to_state(_scene_data.lesson, _scene_data.part)
	OS.alert(tr("key_done_part"), tr("key_title_congratulations"))
	TypeEngine.scene_mediator[TypeEngine.lessons_scene] = true
	get_tree().change_scene_to_file(TypeEngine.lessons_scene)

func play_sound(path:String):
	$AudioStreamPlayer2D.stream = load(path)
	$AudioStreamPlayer2D.play()

func _on_exit_pressed():
	TypeEngine.scene_mediator[TypeEngine.lessons_scene] = false
	get_tree().change_scene_to_file(TypeEngine.lessons_scene)

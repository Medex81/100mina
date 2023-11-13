# Learning step.
# When the next step is completed, the next step is activated and started.
# If a step is marked as a pause, we activate but do not start the next step.
# You can remove the step from the pause by calling the handler through the group.
extends Panel

class_name TutorStep

const group_name = "tutor_next_step"
const group_method = "show_step"

@export var _hint:String
# after this element there will be a pause, the next element will only activate
@export var is_paused:bool = false

var is_active_step:bool = false
var _next_step:TutorStep = null

func _ready():
	add_to_group(group_name)
	hide()
	
	# check your position in the parent
	var children_array = get_parent().get_children() as Array
	var index = children_array.find(self)
	# if the first ones, then we activate
	if index == 0:
		is_active_step = true
	# find the next element and save it
	if index + 1 < children_array.size():
		_next_step = children_array[index + 1]

	if is_active_step:
		show_step()
	
func show_step():
	if is_active_step:
		get_parent().show()
		show()
		if not _hint.is_empty():
			$margin/hint.text = tr(_hint)
			
func hide_step():
	is_active_step = false
	if _next_step == null:
		TypeEngine.set_tutor_done(get_parent().name)
		get_parent().queue_free()
		return
	# Hiding ourselves and the parent
	get_parent().hide()
	hide()
	# Activate the next step
	_next_step.is_active_step = true
	if is_paused == false:
		_next_step.show_step()



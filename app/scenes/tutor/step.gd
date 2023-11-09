# Шаг обучения.
# При завершении очередного шага активируется и запускается следующий шаг.
# Если шаг помечен как пауза, активируем но не запускаем следующий шаг.
# Снять шаг с паузы можно через вызов обработчика через группу. 
extends Panel

class_name TutorStep

const group_name = "tutor_next_step"
const group_method = "show_step"

@export var _hint:String
# после этого элемента будет пауза, следующий элемент только активировать
@export var is_paused:bool = false

var is_active_step:bool = false
var _next_step:TutorStep = null

func _ready():
	add_to_group(group_name)
	hide()
	
	# проверяем свою позицию в родителе
	var children_array = get_parent().get_children() as Array
	var index = children_array.find(self)
	# если первые, то активируемся
	if index == 0:
		is_active_step = true
	# находим следующий элемент и сохраняем его
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
	# Скрываем себя и родителя
	get_parent().hide()
	hide()
	# Активируем следующий шаг
	_next_step.is_active_step = true
	if is_paused == false:
		_next_step.show_step()



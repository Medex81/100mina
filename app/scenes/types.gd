extends Control

@export_file("*.tscn") var new_kb_tutor:String
@export_file("*.tscn") var keyboard_start_tutor:String
var _scene_data:KeyboardDataResource
var _delta = 0
var _svg_accum = 0
var _svg_accum_session = 0
var _svg_counter = 0
var _svg_counter_session = 0
var _last_tick = 0
const _svg_max = 10
const _delta_max = 3000
const _msec_in_min = 60000

func _ready():
	_scene_data = TypeEngine.scene_mediator.get(TypeEngine.c_keyboard_scene, null) as KeyboardDataResource
	if _scene_data:
		state(_scene_data.edit_mode)
		if _scene_data.edit_mode:
			if not new_kb_tutor.is_empty():
				if not new_kb_tutor.is_empty() and not TypeEngine.is_tutor_done(new_kb_tutor.get_file().get_basename()):
					help_tutor()
		else:
			if not keyboard_start_tutor.is_empty() and not TypeEngine.is_tutor_done(keyboard_start_tutor.get_file().get_basename()):
				TypeEngine.add_tutor(keyboard_start_tutor, self)
		
func state(mode:bool):
	$help.visible = mode
	$fingers.visible = !mode
	$results.visible = !mode
		
func help_tutor():
	TypeEngine.add_tutor(new_kb_tutor, self)

func _on_type_area_send_next_symbol(_symbol):
	if _last_tick > 0:
		_delta = Time.get_ticks_msec() - _last_tick
		_last_tick = Time.get_ticks_msec()
		if _delta < _delta_max:
			_svg_accum += _delta
			_svg_accum_session += _delta
			_svg_counter += 1
			_svg_counter_session += 1
			@warning_ignore("integer_division")
			$results/sp_session.text = tr("key_hint_type_speed_session").format([_msec_in_min / (_svg_accum_session / _svg_counter_session)])
			if _svg_counter == _svg_max:
				@warning_ignore("integer_division")
				$results/spm.text = tr("key_hint_type_speed").format([_msec_in_min / (_svg_accum / _svg_max)])
				_svg_counter = 0
				_svg_accum = 0
	else:
		_last_tick = Time.get_ticks_msec()

extends Panel

signal send_need_update()

func _ready():
	add_items_filtered()
		
func add_items_filtered(filter:String = ""):
	$margin/VBoxContainer/lang_list.clear()
	for lang in TypeEngine.get_supported_lang_list():
		if filter.to_lower() in lang.to_lower() or filter.is_empty():
			$margin/VBoxContainer/lang_list.add_item(lang)

func _on_lang_text_submitted(new_text):
	add_items_filtered(new_text)

func _on_reject_pressed():
	visible = false

func _on_save_pressed():
	var lang:String
	var author:String
	var title:String
	var select_id = $margin/VBoxContainer/lang_list.get_selected_items()
	if select_id.size() > 0:
		lang = $margin/VBoxContainer/lang_list.get_item_text(select_id[0]).to_snake_case()
	else:
		OS.alert(tr("key_find_lang"), tr("key_error"))
		return
		
	if $margin/VBoxContainer/author.text.is_empty():
		OS.alert(tr("key_add_author"), tr("key_error"))
		return
	else:
		author = $margin/VBoxContainer/author.text.to_snake_case()
	
	if $margin/VBoxContainer/title.text.is_empty():
		OS.alert(tr("key_add_title"), tr("key_error"))
		return
	else:
		title = $margin/VBoxContainer/title.text.to_snake_case()
		
	TypeEngine.make_lesson("{0}_{1}".format([author, title]), {TypeEngine.key_lang:lang})
		
	visible = false
	
	emit_signal("send_need_update")


func _on_add_pressed():
	visible = true

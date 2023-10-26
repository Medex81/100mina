extends VBoxContainer

signal send_chapter_save(symbols:String)

func _on_save_pressed():
	emit_signal("send_chapter_save", $symbols.text)
	
func set_symbols(symbols:String):
	$symbols.text = symbols

func _on_remove_pressed():
	$symbols.text = ""

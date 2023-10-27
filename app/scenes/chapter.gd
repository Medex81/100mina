# Characters for typing on the keyboard. You can add and edit for a part.
extends VBoxContainer

# we send the signal to the part for saving
signal send_chapter_save(symbols:String)

func _on_save_pressed():
	emit_signal("send_chapter_save", $symbols.text)
# A part is selected and you need to display its symbols in the symbol editor
func set_symbols(symbols:String):
	$symbols.text = symbols

# the signal handler is out of the part, the part has been deleted and the character editor needs to be cleaned up
func _on_remove_pressed():
	$symbols.text = ""

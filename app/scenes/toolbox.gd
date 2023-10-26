extends VBoxContainer


func _on_export_pressed():
	$file_export.visible = true

func _on_import_pressed():
	$file_import.visible = true

func _on_help_pressed():
	$help_window.visible = true

func _on_help_window_close_requested():
	$help_window.visible = false

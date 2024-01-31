extends PopupPanel


func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	$".".hide()


func _on_visibility_changed():
	if visible:
		$MarginContainer/VBoxContainer/HBoxContainer/No.grab_focus()

extends PopupPanel


func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	$".".hide()

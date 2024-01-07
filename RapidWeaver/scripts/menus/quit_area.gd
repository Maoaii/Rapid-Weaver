extends Area2D


func _on_area_entered(area):
	if area.is_in_group("Hook"):
		$PopupPanel.show()


func _on_no_pressed():
	$PopupPanel.hide()


func _on_yes_pressed():
	get_tree().quit()

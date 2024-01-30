extends Area2D


func _on_area_entered(area):
	if area.is_in_group("Hook"):
		$Settings.visible = true
		get_tree().paused = true


func _on_settings_popup_hide():
	get_tree().paused = false


func _on_body_entered(body):
	if body.is_in_group("Player"):
		$Settings.visible = true
		get_tree().paused = true

func _on_mouse_entered():
	$ColorRect.show()


func _on_mouse_exited():
	$ColorRect.hide()

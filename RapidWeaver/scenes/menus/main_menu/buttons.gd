extends VBoxContainer


func _ready() -> void:
	if OS.has_feature("web"):
		get_node("Quit").hide()
	
	var children: Array[Node] = get_children()
	children[0].grab_focus()


func _on_start_pressed():
	SceneTransition.change_scene("res://scenes/world.tscn")


func _on_settings_pressed():
	SceneTransition.change_scene("res://scenes/menus/settings_menu/settings.tscn")


func _on_quit_pressed():
	get_tree().quit()

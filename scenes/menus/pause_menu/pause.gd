extends Control

var is_paused: bool = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		set_is_paused(!is_paused)

func set_is_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	if visible:
		$CenterContainer/VBoxContainer/VBoxContainer/Resume.grab_focus()


func _on_resume_pressed():
	set_is_paused(false)

func _on_menu_pressed():
	set_is_paused(false)
	SceneTransition.change_scene("res://scenes/menus/main_menu/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()




extends Control

@onready var score_label: Label = $CenterContainer/VBoxContainer/Scores/Score
@onready var highscore_label: Label = $CenterContainer/VBoxContainer/Scores/Highscore

func _ready() -> void:
	score_label.text = "Score: " + str(ScoreManager.get_score())
	highscore_label.text = "Highscore: " + str(ScoreManager.get_score())
	
	$CenterContainer/VBoxContainer/Buttons/Restart.grab_focus()


func _on_restart_pressed():
	SceneTransition.change_scene("res://scenes/world.tscn")


func _on_main_menu_pressed():
	SceneTransition.change_scene("res://scenes/menus/main_menu/main_menu.tscn")


func _on_quit_pressed():
	get_tree().quit()

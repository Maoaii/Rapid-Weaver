extends Control

@onready var highscore_label: Label = $MarginContainer/VBoxContainer/Highscore

func _ready():
	var stored_highscore = SaveGame.load_data("Highscore").get("Highscore")
	
	if stored_highscore == null:
		stored_highscore = 0
	
	highscore_label.text = "Highscore: " + str(stored_highscore)

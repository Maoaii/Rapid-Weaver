extends Node2D

@onready var highscore_label: Label = $PanelContainer/Label

func _ready() -> void:
	highscore_label.text = "Highscore: " + str(ScoreManager.get_highscore())

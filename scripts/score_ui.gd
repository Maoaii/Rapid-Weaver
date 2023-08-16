class_name ScoreUI
extends Control

func _ready() -> void:
	$HBoxContainer/Score.text = '0'
	$HBoxContainer/AnimationPlayer.play("float")

func update_score_label(new_score: int) -> void:
	$HBoxContainer/Score.text = str(new_score)

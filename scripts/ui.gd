extends CanvasLayer

@export var score_ui: ScoreUI


func _process(_delta: float) -> void:
	if score_ui:
		score_ui.update_score_label(Global.score)

extends CanvasLayer

@export var score_ui: ScoreUI


func _ready() -> void:
	if score_ui:
		EventBus._on_score_changed.connect(update_score_label)

func update_score_label(new_score: int) -> void:
	score_ui.update_score_label(new_score)

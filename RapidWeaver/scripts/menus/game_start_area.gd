extends Area2D


func _on_body_exited(body):
	if body.is_in_group("Player"):
		EventBus._on_game_started.emit()

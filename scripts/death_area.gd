class_name DeathArea
extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		EventBus._on_player_hurt.emit()

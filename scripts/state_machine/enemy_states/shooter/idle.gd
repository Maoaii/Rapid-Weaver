extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Idle")

func _on_aggro_range_body_entered(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Shooting", {"player": body})


func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Dead")

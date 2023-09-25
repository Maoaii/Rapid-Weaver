extends EnemyState

var player: Player

func _enter(msg := {}) -> void:
	enemy.play_animation("Shooting")
	
	if msg.has("player"):
		player = msg.get("player")
	
	enemy.shoot_timer.start()


func _exit() -> void:
	player = null
	enemy.shoot_timer.stop()


func _on_aggro_range_body_exited(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Idle")


func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Dead")


func _on_shoot_timer_timeout():
		enemy.shoot(player.position)

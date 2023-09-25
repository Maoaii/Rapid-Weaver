extends EnemyState

var player: Player

func _enter(msg := {}) -> void:
	enemy.play_animation("Shooting")
	
	if msg.has("player"):
		player = msg.get("player")
	
	get_tree().create_timer(enemy.shoot_time).timeout.connect(shoot)


func _exit() -> void:
	player = null

func shoot():
	if not is_instance_valid(player):
		return
	
	enemy.shoot(player.position)
	
	get_tree().create_timer(enemy.shoot_time).timeout.connect(shoot)

func _on_aggro_range_body_exited(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Idle")


func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		state_machine.transition_to("Dead")

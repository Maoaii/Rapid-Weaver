extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Idle")
	
	enemy.idle_timer.start(enemy.idle_length)
	
	await enemy.idle_timer.timeout
	idle_timer_ended()

func _exit() -> void:
	enemy.idle_timer.stop()

func _physics_update(_delta: float) -> void:
	enemy.x_dir = Vector2.ZERO

func idle_timer_ended() -> void:
	state_machine.transition_to("Walking")


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		state_machine.transition_to("Dead")
